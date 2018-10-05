<%@ Page Language="AVR" MasterPageFile="~/BasicMasterPage.master" AutoEventWireup="false" CodeFile="Customers.aspx.vr" Inherits="views_Customers" Title="Untitled Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadPlaceHolder" Runat="Server">
    <link rel="stylesheet" href="assets/vendors/tabulator/tabulator.min.css"/>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder" Runat="Server">
    <div class="container">
        <main>

            <h2 class="mt-5 content-container">Populate Tabulator's</a> client-side grid with an AVR Web API</h2>
            <p class="lead">This page calls the <code>/api/customers</code> route from Tabulator's JavaScript configuration.
                The result is a data table that has many options. See the the <a href="http://tabulator.info/">Tabulator site</a> for details. Use the 
                filter field to filter the grid on the customer name. The default 
                start page in Visual Studio should be set to <code>customers</code>.
            </p>

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

        </main>
   
    </div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptPlaceHolder" Runat="Server">
    <script src="../assets/js/js-lib.js"></script>        
    <script src="../assets/vendors/tabulator/tabulator.min.js"></script>        
    <script src="../assets/js/pages/views-customers.aspx.js"></script>           
</asp:Content>

