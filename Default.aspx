<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="form-container">
        <h2>Welcome to Legacy Web Application</h2>
        <p>This is a sample ASP.NET Web Forms application targeting .NET Framework 3.5.</p>
        
        <div class="form-section">
            <h3>Quick Contact Form</h3>
            <div class="form-row">
                <asp:Label ID="lblName" runat="server" Text="Full Name:" CssClass="form-label" AssociatedControlID="txtName"></asp:Label>
                <asp:TextBox ID="txtName" runat="server" CssClass="form-input" placeholder="Enter your full name"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvName" runat="server" 
                    ControlToValidate="txtName" 
                    ErrorMessage="Name is required" 
                    CssClass="error-message" 
                    Display="Dynamic">
                </asp:RequiredFieldValidator>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblEmail" runat="server" Text="Email Address:" CssClass="form-label" AssociatedControlID="txtEmail"></asp:Label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-input" placeholder="Enter your email address"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" 
                    ControlToValidate="txtEmail" 
                    ErrorMessage="Email is required" 
                    CssClass="error-message" 
                    Display="Dynamic">
                </asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator ID="revEmail" runat="server" 
                    ControlToValidate="txtEmail" 
                    ErrorMessage="Please enter a valid email address" 
                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" 
                    CssClass="error-message" 
                    Display="Dynamic">
                </asp:RegularExpressionValidator>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblPhone" runat="server" Text="Phone Number:" CssClass="form-label" AssociatedControlID="txtPhone"></asp:Label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-input" placeholder="(555) 123-4567"></asp:TextBox>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblCompany" runat="server" Text="Company:" CssClass="form-label" AssociatedControlID="ddlCompany"></asp:Label>
                <asp:DropDownList ID="ddlCompany" runat="server" CssClass="form-input">
                    <asp:ListItem Value="" Text="-- Select Company Type --"></asp:ListItem>
                    <asp:ListItem Value="small" Text="Small Business (1-50 employees)"></asp:ListItem>
                    <asp:ListItem Value="medium" Text="Medium Business (51-250 employees)"></asp:ListItem>
                    <asp:ListItem Value="large" Text="Large Enterprise (250+ employees)"></asp:ListItem>
                    <asp:ListItem Value="nonprofit" Text="Non-Profit Organization"></asp:ListItem>
                    <asp:ListItem Value="government" Text="Government Agency"></asp:ListItem>
                </asp:DropDownList>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblServices" runat="server" Text="Interested Services:" CssClass="form-label"></asp:Label>
                <div style="margin-top: 5px;">
                    <asp:CheckBox ID="chkWebDev" runat="server" Text="Web Development" />
                    <br />
                    <asp:CheckBox ID="chkConsulting" runat="server" Text="IT Consulting" />
                    <br />
                    <asp:CheckBox ID="chkSupport" runat="server" Text="Technical Support" />
                    <br />
                    <asp:CheckBox ID="chkHosting" runat="server" Text="Web Hosting" />
                </div>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblPriority" runat="server" Text="Priority Level:" CssClass="form-label"></asp:Label>
                <div style="margin-top: 5px;">
                    <asp:RadioButton ID="rbLow" runat="server" GroupName="Priority" Text="Low Priority" />
                    <br />
                    <asp:RadioButton ID="rbMedium" runat="server" GroupName="Priority" Text="Medium Priority" Checked="true" />
                    <br />
                    <asp:RadioButton ID="rbHigh" runat="server" GroupName="Priority" Text="High Priority" />
                    <br />
                    <asp:RadioButton ID="rbUrgent" runat="server" GroupName="Priority" Text="Urgent" />
                </div>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblMessage" runat="server" Text="Message:" CssClass="form-label" AssociatedControlID="txtMessage"></asp:Label>
                <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-input" placeholder="Please describe your requirements..."></asp:TextBox>
            </div>
            
            <div class="form-row">
                <asp:CheckBox ID="chkTerms" runat="server" Text="I agree to the terms and conditions" />
                <div id="chkTermsError" class="error-message" style="display:none;">You must agree to the terms and conditions</div>
            </div>
            
            <div class="form-row text-center">
                <asp:Button ID="btnSubmit" runat="server" Text="Submit Request" CssClass="btn"  />
                <asp:Button ID="btnReset" runat="server" Text="Reset Form" CssClass="btn btn-secondary"  CausesValidation="false" />
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblMessage2" runat="server" CssClass="success-message" Visible="false"></asp:Label>
            </div>
        </div>
        
        <div class="form-section">
            <h3>Current Date and Time</h3>
            <p>Server Time: <asp:Label ID="lblDateTime" runat="server"></asp:Label></p>
            <asp:Button ID="btnRefresh" runat="server" Text="Refresh Time" CssClass="btn btn-secondary"  CausesValidation="false" />
        </div>
        
        <div class="form-section">
            <h3>File Upload Example</h3>
            <div class="form-row">
                <asp:Label ID="lblFile" runat="server" Text="Select File:" CssClass="form-label" AssociatedControlID="fileUpload"></asp:Label>
                <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-input" />
            </div>
            <div class="form-row">
                <asp:Button ID="btnUpload" runat="server" Text="Upload File" CssClass="btn"  CausesValidation="false" />
                <asp:Label ID="lblUploadMessage" runat="server" CssClass="success-message"></asp:Label>
            </div>
        </div>
    </div>
    
    <script type="text/javascript">
        function validateForm() {
            var name = document.getElementById('<%= txtName.ClientID %>').value;
            var email = document.getElementById('<%= txtEmail.ClientID %>').value;
            var terms = document.getElementById('<%= chkTerms.ClientID %>').checked;
            var errorDiv = document.getElementById('chkTermsError');
            
            // Hide error message first
            errorDiv.style.display = 'none';
            
            if (name == '') {
                alert('Please enter your name');
                return false;
            }
            
            if (email == '') {
                alert('Please enter your email address');
                return false;
            }
            
            if (!terms) {
                errorDiv.style.display = 'block';
                alert('You must agree to the terms and conditions');
                return false;
            }
            
            return true;
        }
        
        function resetForm() {
            if (confirm('Are you sure you want to reset the form?')) {
                document.getElementById('<%= txtName.ClientID %>').value = '';
                document.getElementById('<%= txtEmail.ClientID %>').value = '';
                document.getElementById('<%= txtPhone.ClientID %>').value = '';
                document.getElementById('<%= txtMessage.ClientID %>').value = '';
                document.getElementById('<%= chkTerms.ClientID %>').checked = false;
                document.getElementById('chkTermsError').style.display = 'none';
                return true;
            }
            return false;
        }
        
        // Add submit button click validation
        window.onload = function() {
            var submitBtn = document.getElementById('<%= btnSubmit.ClientID %>');
            if (submitBtn) {
                submitBtn.onclick = function() { return validateForm(); };
            }
        };
    </script>
</asp:Content>