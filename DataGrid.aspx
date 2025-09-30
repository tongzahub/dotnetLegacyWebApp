<%@ Page Title="Data Grid Example" Language="C#" MasterPageFile="~/Site.Master" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div style="max-width: 1000px; margin: 0 auto;">
        <h2>Employee Data Grid Example</h2>
        <p>This page demonstrates the use of GridView control with sorting, paging, and basic formatting.</p>
        
        <div class="form-section">
            <h3>Search and Filter</h3>
            <div class="form-row">
                <asp:Label ID="lblSearch" runat="server" Text="Search by Name:" CssClass="form-label" AssociatedControlID="txtSearch"></asp:Label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-input" placeholder="Enter employee name" style="width: 250px; display: inline-block;"></asp:TextBox>
                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn"  />
                <asp:Button ID="btnShowAll" runat="server" Text="Show All" CssClass="btn btn-secondary"  />
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblDepartment" runat="server" Text="Filter by Department:" CssClass="form-label" AssociatedControlID="ddlDepartment"></asp:Label>
                <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-input" style="width: 200px; display: inline-block;">
                    <asp:ListItem Value="" Text="All Departments"></asp:ListItem>
                    <asp:ListItem Value="IT" Text="Information Technology"></asp:ListItem>
                    <asp:ListItem Value="HR" Text="Human Resources"></asp:ListItem>
                    <asp:ListItem Value="Finance" Text="Finance"></asp:ListItem>
                    <asp:ListItem Value="Marketing" Text="Marketing"></asp:ListItem>
                    <asp:ListItem Value="Sales" Text="Sales"></asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>
        
        <div class="grid-container">
            <asp:Label ID="lblRecordCount" runat="server" Text="" CssClass="form-label"></asp:Label>
            
            <asp:GridView ID="gvEmployees" runat="server" 
                CssClass="data-grid"
                AutoGenerateColumns="false" 
                AllowPaging="true" 
                AllowSorting="true"
                PageSize="10"
                                                                                EmptyDataText="No employees found matching your criteria.">
                
                <HeaderStyle BackColor="#2c3e50" ForeColor="White" Font-Bold="true" />
                <RowStyle BackColor="White" />
                <AlternatingRowStyle BackColor="#f9f9f9" />
                <PagerStyle BackColor="#ecf0f1" ForeColor="#2c3e50" HorizontalAlign="Center" />
                <SelectedRowStyle BackColor="#3498db" ForeColor="White" />
                
                <Columns>
                    <asp:BoundField DataField="EmployeeID" HeaderText="ID" SortExpression="EmployeeID" ItemStyle-Width="50px" />
                    
                    <asp:BoundField DataField="FirstName" HeaderText="First Name" SortExpression="FirstName" ItemStyle-Width="100px" />
                    
                    <asp:BoundField DataField="LastName" HeaderText="Last Name" SortExpression="LastName" ItemStyle-Width="100px" />
                    
                    <asp:BoundField DataField="Department" HeaderText="Department" SortExpression="Department" ItemStyle-Width="120px" />
                    
                    <asp:BoundField DataField="Position" HeaderText="Position" SortExpression="Position" ItemStyle-Width="150px" />
                    
                    <asp:BoundField DataField="HireDate" HeaderText="Hire Date" SortExpression="HireDate" DataFormatString="{0:MM/dd/yyyy}" ItemStyle-Width="100px" />
                    
                    <asp:BoundField DataField="Salary" HeaderText="Salary" SortExpression="Salary" DataFormatString="{0:C}" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Right" />
                    
                    <asp:CheckBoxField DataField="IsActive" HeaderText="Active" SortExpression="IsActive" ItemStyle-Width="60px" ItemStyle-HorizontalAlign="Center" />
                    
                    <asp:TemplateField HeaderText="Actions" ItemStyle-Width="120px">
                        <ItemTemplate>
                            <asp:Button ID="btnView" runat="server" Text="View" CommandName="ViewEmployee" CommandArgument='<%# Eval("EmployeeID") %>' CssClass="btn" style="font-size: 11px; padding: 4px 8px;" />
                            <asp:Button ID="btnEdit" runat="server" Text="Edit" CommandName="EditEmployee" CommandArgument='<%# Eval("EmployeeID") %>' CssClass="btn btn-secondary" style="font-size: 11px; padding: 4px 8px;" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                
                <PagerTemplate>
                    <div style="padding: 10px; text-align: center;">
                        <asp:Button ID="btnFirst" runat="server" Text="<<" CommandName="Page" CommandArgument="First" CssClass="btn" style="padding: 4px 8px; margin: 2px;" />
                        <asp:Button ID="btnPrev" runat="server" Text="<" CommandName="Page" CommandArgument="Prev" CssClass="btn" style="padding: 4px 8px; margin: 2px;" />
                        
                        Page <asp:Label ID="lblCurrentPage" runat="server" Text='<%# gvEmployees.PageIndex + 1 %>'></asp:Label> 
                        of <asp:Label ID="lblTotalPages" runat="server" Text='<%# gvEmployees.PageCount %>'></asp:Label>
                        
                        <asp:Button ID="btnNext" runat="server" Text=">" CommandName="Page" CommandArgument="Next" CssClass="btn" style="padding: 4px 8px; margin: 2px;" />
                        <asp:Button ID="btnLast" runat="server" Text=">>" CommandName="Page" CommandArgument="Last" CssClass="btn" style="padding: 4px 8px; margin: 2px;" />
                    </div>
                </PagerTemplate>
            </asp:GridView>
        </div>
        
        <div class="form-section">
            <h3>Grid Actions</h3>
            <div class="form-row">
                <asp:Button ID="btnAddNew" runat="server" Text="Add New Employee" CssClass="btn"  />
                <asp:Button ID="btnExport" runat="server" Text="Export to Excel" CssClass="btn btn-secondary"  />
                <asp:Button ID="btnRefreshGrid" runat="server" Text="Refresh Data" CssClass="btn btn-secondary"  />
            </div>
        </div>
        
        <asp:Panel ID="pnlEmployeeDetails" runat="server" CssClass="form-section" Visible="false">
            <h3>Employee Details</h3>
            <div style="background-color: #ecf0f1; padding: 15px; border-radius: 5px;">
                <asp:Label ID="lblEmployeeDetails" runat="server" Text=""></asp:Label>
                <br /><br />
                <asp:Button ID="btnCloseDetails" runat="server" Text="Close" CssClass="btn btn-secondary"  />
            </div>
        </asp:Panel>
        
        <div class="form-section">
            <h3>Summary Statistics</h3>
            <div style="display: table; width: 100%;">
                <div style="display: table-cell; width: 25%; text-align: center; padding: 10px;">
                    <strong>Total Employees:</strong><br />
                    <asp:Label ID="lblTotalEmployees" runat="server" Text="0" style="font-size: 18px; color: #3498db;"></asp:Label>
                </div>
                <div style="display: table-cell; width: 25%; text-align: center; padding: 10px;">
                    <strong>Active Employees:</strong><br />
                    <asp:Label ID="lblActiveEmployees" runat="server" Text="0" style="font-size: 18px; color: #27ae60;"></asp:Label>
                </div>
                <div style="display: table-cell; width: 25%; text-align: center; padding: 10px;">
                    <strong>Departments:</strong><br />
                    <asp:Label ID="lblDepartmentCount" runat="server" Text="0" style="font-size: 18px; color: #f39c12;"></asp:Label>
                </div>
                <div style="display: table-cell; width: 25%; text-align: center; padding: 10px;">
                    <strong>Avg. Salary:</strong><br />
                    <asp:Label ID="lblAvgSalary" runat="server" Text="$0" style="font-size: 18px; color: #e74c3c;"></asp:Label>
                </div>
            </div>
        </div>
    </div>
    
    <script type="text/javascript">
        function confirmDelete(employeeName) {
            return confirm('Are you sure you want to delete employee: ' + employeeName + '?');
        }
        
        function highlightRow(row) {
            row.style.backgroundColor = '#3498db';
            row.style.color = 'white';
        }
        
        function unhighlightRow(row) {
            var rowIndex = row.rowIndex;
            if (rowIndex % 2 == 0) {
                row.style.backgroundColor = '#f9f9f9';
            } else {
                row.style.backgroundColor = 'white';
            }
            row.style.color = 'black';
        }
    </script>
</asp:Content>