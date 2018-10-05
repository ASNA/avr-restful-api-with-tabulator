## Using a RESTful API with AVR for .NET to populate a client-side grid

A client-side grid is dynamically-populated grid that displays data in rows and columns. Think of it as a more powerful, dynamic substitute for ASP.NET's GridView. Client-side grids generally have features like sorting, filtering, paging, and editing as well as many other more esoteric capabilities. The web page below shows the client-side that this example features: 

![](https://asna.com/filebin/marketing/article-figures/tabulator-screen-shot.png)


Client-side grids aren't data-bound on the server-side like the GridView, rather they are fed Json from JavaScript on the client side. Some of them generate HTML tables without much regard for mobile responsivenes. If that's important to you, investigate carefully. Most of these are open source and free.

* [DataTables](https://datatables.net/)
* [Tabulator](http://tabulator.info/)
* [dgrid](http://dgrid.io/)
* [jsGrid](https://js-grid.com)
* [jqGrid](http://www.trirand.com/blog/)
* [SlickGrid](https://jspreadsheets.com/slickgrid.html)

DataTables is powerful and relatively simple to use, but it has a dependency on [jQuery](https://jquery.com), a very popular JavaScript library. A jQuery dependence isn't that bad&mdash;Bootstrap 4 also requires jQuery so jQuery is usually present anyway. However, I like to avoid jQuery when I can. That's one of the reasons this example uses Tabulator. It is a pure JavaScript component with no other dependencies. 

Another plus in Tabulator's favor is that, surprisingly, it doesn't render its grid as an HTML table, rather it renders as a `div` tabs cleverly stitched together with very effectively CSS. This makes the `Tabulator` a lot more responsive than grids that render as an HTML tables. 

I've not used the other grids in the list above, but the code used here for Tabulator is similiar in both concept and execution to the code you'd use for DataTables (and by quickly looking at the docs, most of the others as well). Use this example to get familiar with the general concept of populating a client-grid and then go shopping. Read the docs for each grid above (and any other than you can find) and pick one that works best for you. 

> Warning: JavaScript ahead! To use a client-side grid you're going to need to do some client-side work. That means JavaScript. This article doesn't attempt to teach any JavaScript. If you're not up to speed with JavaScript (and modern Web developers need to be!), take a look at [Web Bos's free 30 day JavaScript coding challenge.](https://javascript30.com/) This is a great introduction to many quick JavaScript concepts. If you like what you see there Wes has many other courses for sale that are highly recommended. (Disclaimer: we are in no way affilated with Wes Bos&mdash;if you google 'learn JavaScrip't you can find many other resources).

### Folder conventions 

| Folder           | Description                                |
|------------------|------------------------------------------|
| /App_Code        | ASP.NET folder for app classes           |
| /assets          | Top-level folder for JavaScript, CSS, Images  |
| /assets/css      | CSS folder                               |
| /assets/images   | Images folder                            |
| /assets/js       | Javascript folder                        |
| /assets/js/pages&nbsp;&nbsp;&nbsp;&nbsp;    | page-specific JavaScript folder          |
| /assets/vendors  | third-party JavaScript folder            |
| /Bin             | ASP.NET Bin folder                       |
| /docs            | app documentation folder                 |
| /views           | views folder (all ASPX pages here)       |

### Getting to it

There are four basic steps to populating Tabulator: 

1. Write the HTML to scaffold up the dynamic grid. 
2. Map the page and API routes
3. Write the AVR controller that fetches data for the grid
4. Write the JavaScript that instances and displays the grid. 

Let's take a closer look at each one:

#### Step 1. The HTML 

The HTML shown below in Figure 1 is what's needed to scaffold up a Tabulator grid. Technically, the last line is the only line needed as the target for Tabulator to inject its grid, but to make this example a little more powerful the HTML is included to filter the grid on the customer name. This HTML is in the `customers.html` page.  

    <div class="table-controls">
        <span>
            <label>Field: </label>
            <select id="filter-field">
                <option value="CMName">Name</option>
            </select>
        </span>
    
        <span>
            <label>Find: </label>
            <input id="filter-value" type="text" placeholder="value to filter">
        </span>
    
        <button id="filter-clear">Clear Filter</button>
    </div>
    <div id="customers-table"></div>
    
HTML references:

* [HTML basics](https://html.com/)
* [Free HTML Web course](https://www.codecademy.com/learn/learn-html)

<small>Figure 1. HTML for Tabulator grid and its set-filter UI.</small>

#### Step 2. The routes.

It only takes a couple of lines of code to map the routes; this is done in the `RegisterRoutes` subroutine in the `global.asax.vr`. The first line maps the route `customers` to the `customers.aspx page` which displays the Tabulator grid. The second line maps the route `api/customers` to the `ListAction` method in the CustomerController class.

    // Map the customers.aspx page to the 'customers' route.
    routes.MapPageRoute("customer_list", "customers", "~/views/customers.aspx")
    
    // Map the CustomerControl.ListAction method the api/customers route.
    RestRouter.Get("api/customers", "ListAction", *TypeOf(CustomerController)) 
    
ASP.NET routing references:

* [See this ASNA.comarticle](https://asna.com/us/tech/kb/doc/asp-net-routing) 
* [Example AVR for .NET project/template](https://github.com/ASNA/avr-restful-api-template).
* [Microsoft ASP.NET routing walkthrough](https://msdn.microsoft.com/en-us/library/dd329551.aspx)

<small>Figure 2. Map routes in Global.asax.vr.</small>

#### Step 3. The AVR controller.

The AVR CustomerController class, which extends the 


is shown below in Figure 3. This is the class that provides the `ListAction` called by the API route registered in Figure 1. Because `CustomerController` extended the ASNA.JsonRestRouting.Controller, any return value is converted to Json automatically. 

The code here is pretty basic AVR for .NET coding. Its `ListAction` method returns an array of `CustomerEntity`, implicitly converted to Json. To create this array, the `EntityList` variable, which is an instance of type `List<T>` class (in this case, a list of `CustomerEntity`), is populated by reading through a file, creating a `CustomerEntity` instance for each record read, and adding that instance to `EntityList`. `EntityList`'s `ToArray` method converts the list to an array. 

> The use of `List<T>` in this example is a very frequently used pattern in RESTful services when needing to return an array of object instances. The `List<T>` represents a list of a given type (that's what the `T` stands for) and can have as many items added to as necessary. Its `ToArray` method makes it easy to get an array of `T` out of the list. 

    Using System
    Using System.Collections.Generic
    
    BegClass CustomerController Access(*Public) Extends(ASNA.JsonRestRouting.Controller)
    
        DclDB pgmDB DBName( "*PUBLIC/DG Net Local" )
    
        DclDiskFile  CustomerByName +
                Type( *Input  ) +
                Org( *Indexed ) +
                Prefix( Customer_ ) +
                File( "Examples/CMastNewL2" ) +
                DB( pgmDB ) +
                ImpOpen( *No )
    
        // Example ShowAction method. 
        BegFunc ListAction Access(*Public) Type(CustomerEntity) Rank(1) 
            DclFld EntityList Type(List(*Of CustomerEntity)) New()
            DclFld Entity Type(CustomerEntity) 
    
            Connect pgmDB
            Open CustomerByName
    
            Read CustomerByName
            DoWhile NOT CustomerByName.IsEof()
                Entity = PopulateCustomerEntity()
                EntityList.Add(Entity)
                Read CustomerByName
            EndDo
    
            Close CustomerByName 
            Disconnect pgmDB 
    
            // The ASNA.JsonRestRouting router implicitly maps the return type to Json. 
            LeaveSr EntityList.ToArray() 
        EndFunc        
    
        BegFunc PopulateCustomerEntity Type(CustomerEntity)
            DclFld Entity Type(CustomerEntity) New()
    
            Entity.CMCustNo    = *This.Customer_CMCustNo
            Entity.CMName      = *This.Customer_CMName.Trim()
            Entity.CMAddr1     = *This.Customer_CMAddr1.Trim()
            Entity.CMCity      = *This.Customer_CMCity.Trim()
            Entity.CMState     = *This.Customer_CMState.Trim()
            Entity.CMCntry     = *This.Customer_CMCntry.Trim()
            Entity.CMPostCode  = *This.Customer_CMPostCode.Trim()
            Entity.CMActive    = *This.Customer_CMActive
            Entity.CMFax       = *This.Customer_CMFax
            Entity.CMPhone     = *This.Customer_CMPhone.Trim()
    
            LeaveSr Entity
        EndFunc
    
    EndClass
    
    // Example entity class. 
    BegClass CustomerEntity Access(*Public)
        DclProp CMCustNo    Type(*Integer4) Access(*Public)
        DclProp CMName      Type(*String) Access(*Public)
        DclProp CMAddr1     Type(*String) Access(*Public)
        DclProp CMCity      Type(*String) Access(*Public)
        DclProp CMState     Type(*String) Access(*Public)
        DclProp CMCntry     Type(*String) Access(*Public)
        DclProp CMPostCode  Type(*String) Access(*Public)
        DclProp CMActive    Type(*String) Access(*Public)
        DclProp CMFax       Type(*Packed) Len(9,0) Access(*Public)
        DclProp CMPhone     Type(*String) Access(*Public)
    EndClass

<small>Figure 3. Customer controller.</small>

AVR controller references: 

* [`List<T>` .NET generic collection](https://goo.gl/575JNC)


#### Step 4. The JavaScript. 

If you're not familiar with JavaScript, the JavaScript included here may seem a little daunting. But taken a chunk at a time you'll notice that any one chunk isn't doing very much. Much of the code is declaring the Tabulator grid; there is only about 15 lines of execuatable JavaScript you need to get your arms around. 

The JavaScript below is split into six chunks. Here is what each chunk is doing:

* **Chunk 1. Set strict mode.** This line sets JavaScript's "strict" mode on. Using [strict mode](https://goo.gl/vVS7Or) helps avoid many JavaScript errors. Using strict mode in *all* of your JavaScript is highly recommended. 

* **Chunk 2. Instance the Tabulator object.** Instance the Tabulator object. This instances the Tabulator object into the DOM at the location specified (in this case, the element with the `customers-table1` id) and with the options specified. [This is covered in the Tabulator docs.](http://tabulator.info/docs/4.0). Note also that chunks 2-6 are all inside the `createTable` function declared in this chunk.

* **Chunk 3. Function to filter grid data.** This function uses Tabulator's `setFilter` method to [filter the data in the Tabulator grid](http://tabulator.info/docs/4.0/filter).

* **Chunk 4. Click event handler for the 'Clear filter' button.** This event handler is raised when the 'Clear filter' button (which has the element id `filter-clear`) is clicked. It clears the current filter.

* **Chunk 5. Keyup event handler to call funtion to impose a filter.** This event handler is raised when the `keyup` event occurs in the 'Find:' input element (which has the element id of `filter-value`).

* **Chunk 6. Call createTable when the page is ready.** This chunk registererd causes the `createTable` to be called when the `asna.dom.documentReady` function (which is in in the `js.lib.js` file) is called. It is called when the page is finished loading. `asna.dom.documentReady` is a plain-vanilla version of jQuery's `ready function.

&nbsp;

    // -------
    // Chunk 1. 
    // -------
    "use strict";
    
    // -------
    // Chunk 2. 
    // -------
    const createTable = function() {
        // Create a new Tabulator object. 
        var table = new Tabulator("#customers-table", {
            height: 418, // setting height enables Tabulator's Virtual DOM which improves render speed dramatically.
            layout: "fitDataFill",
            ajaxURL: "/api/customers",
            pagination: "local",
            paginationSize: 12,
            columns: [ 
                { title: "Number", field: "CMCustNo", align: "left", width: 80 },
                { title: "Name", field: "CMName", width: 550 },
                { title: "Address", field: "CMAddr1", align: "left", width: 448 }
            ],
            rowClick: function (e, row) { 
                alert("Customer number " + row.getData().CMCustNo + " clicked");
                // Do something here when a row is clicked. 
            },
        });

        // -------
        // Chunk 3. 
        // -------
        // Called when the `keyup` event occurs in the `filter-value` input tag. 
        const updateFilter = function(value) {
            const filterField = document.getElementById('filter-field').value;
    
            table.setFilter(filterField, 'like', value);
        }

        // -------
        // Chunk 4. 
        // -------
        // Clear filter when 'filter-clear' button clicked.
        document.getElementById('filter-clear').
            addEventListener('click', function () {
                filterValue.value = '';
            });
    
        // -------
        // Chunk 5. 
        // -------
        // Filter data when 'filter-value' changes. 
        document.getElementById('filter-value').
            addEventListener('keyup', function () {
                // Pass current filter value to updateFilter.
                updateFilter(this.value);
            });
    }

    // -------
    // Chunk 6. 
    // -------
    asna.dom.documentReady(function () {
        createTable();
    });

<small>Figure 4. JavaScript to instance and configure a Tabulator grid.</small>

JavaScript references

* [JavaScript info on Mozilla Dev Network](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
* [Tabulator grid](http://tabulator.info/)

**For internal use**

    C:\Users\roger\Documents\Programming\AVR\Web\RESTful-with-Tabulator