<%@ Application Language="AVR" %>
<%@ Import namespace="System.Web.Routing" %>
<%@ Import namespace="ASNA.JsonRestRouting" %>

<script runat="server">

    BegSr Application_Start
        DclSrParm sender Type(*Object)
        DclSrParm e Type(EventArgs)

        // Code that runs on application startup.

        RegisterRoutes(RouteTable.Routes)
    EndSr

    BegSr RegisterRoutes
        DclSrParm routes Type(RouteCollection)

        DclFld restRouter Type(ASNA.JsonRestRouting.Router) 
        restRouter = *New ASNA.JsonRestRouting.Router(routes) 

        // ASPX page routes. 		
        // This support is provided directly by MS .NET.
        routes.MapPageRoute("home", "", "~/views/index.aspx")
        routes.MapPageRoute("customer_list", "customers", "~/views/customers.aspx")


        // RESTful Json routes.
        // This support is provided by the ASNA.JsonRestRouting assembly. Any mapped call to the 
        // routes mapped by the ASNA.JsonRestRouting router return Json. 
        // Don't start routes with "/"! 
        // Specify method parts with {x} syntax. Names entered here _must match_ method parameter names.       
        // Add as many routes here as needed. List them in most-specific to most-general order. 
        RestRouter.Get("api/customers", "ListAction", *TypeOf(CustomerController)) 

        // Route recommendations
        //
        // https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
        // https://www.restapitutorial.com/lessons/httpmethods.html
        //    | HTTP   |
        //    | Verb   | Route                 | Action        | Purpose
        //    | GET    | /contacts             | index action  | get all contacts
        //    | GET    | /contacts/{id}        | show action   | get one contact
        //    | GET    | /contacts/{id}/edit   | edit action   | get a contact for edit 
        //    | POST   | /contacts             | create action | add a contact 
        //    | PUT*   | /contacts             | update action | update a contact
        //    | DELETE | /contacts/{id}        | delete action | delete a contact

        //   * The HTTP PATCH method may be used instead of the PUT method for the update 
        //     operation. Remember, REST is a style, not a standard so there are variations 
        //     in its implementation. You can also expect to find a great deal of debate about 
        //     such matters. As you work with REST, worry less about empirical opinions and 
        //     more about making REST work for you and your application.


    
    EndSr


    BegSr Application_End
        DclSrParm sender Type(*Object)
        DclSrParm e Type(EventArgs)

        //  Code that runs on application shutdown
    EndSr
        
    BegSr Application_Error
        DclSrParm sender Type(*Object)
        DclSrParm e Type(EventArgs)

        // Code that runs when an unhandled error occurs

    EndSr

    BegSr Session_Start
        DclSrParm sender Type(*Object)
        DclSrParm e Type(EventArgs)

        // Code that runs when a new session is started

    EndSr

    BegSr Session_End
        DclSrParm sender Type(*Object)
        DclSrParm e Type(EventArgs)

        // Code that runs when a session ends. 
        // Note: The Session_End event is raised only when the sessionstate mode
        // is set to InProc in the Web.config file. If session mode is set to StateServer 
        // or SQLServer, the event is not raised.

    EndSr

       
</script>
