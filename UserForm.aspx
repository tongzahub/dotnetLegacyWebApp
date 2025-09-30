<%@ Page Title="User Registration Form" Language="C#" MasterPageFile="~/Site.Master" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="form-container">
        <h2>User Registration Form</h2>
        <p>Please fill out all required fields to create your account.</p>
        
        <asp:ValidationSummary ID="vsUserForm" runat="server" 
            CssClass="error-message" 
            HeaderText="Please correct the following errors:" 
            ShowSummary="true" 
            DisplayMode="BulletList" />
        
        <div class="form-section">
            <h3>Personal Information</h3>
            
            <div class="form-row">
                <asp:Label ID="lblFirstName" runat="server" Text="First Name: *" CssClass="form-label" AssociatedControlID="txtFirstName"></asp:Label>
                <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-input" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" 
                    ControlToValidate="txtFirstName" 
                    ErrorMessage="First Name is required" 
                    Text="*" 
                    CssClass="error-message">
                </asp:RequiredFieldValidator>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblLastName" runat="server" Text="Last Name: *" CssClass="form-label" AssociatedControlID="txtLastName"></asp:Label>
                <asp:TextBox ID="txtLastName" runat="server" CssClass="form-input" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvLastName" runat="server" 
                    ControlToValidate="txtLastName" 
                    ErrorMessage="Last Name is required" 
                    Text="*" 
                    CssClass="error-message">
                </asp:RequiredFieldValidator>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblDateOfBirth" runat="server" Text="Date of Birth:" CssClass="form-label" AssociatedControlID="txtDateOfBirth"></asp:Label>
                <asp:TextBox ID="txtDateOfBirth" runat="server" CssClass="form-input" placeholder="MM/DD/YYYY"></asp:TextBox>
                <asp:CompareValidator ID="cvDateOfBirth" runat="server" 
                    ControlToValidate="txtDateOfBirth" 
                    ErrorMessage="Please enter a valid date" 
                    Type="Date" 
                    Operator="DataTypeCheck" 
                    Text="*" 
                    CssClass="error-message">
                </asp:CompareValidator>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblGender" runat="server" Text="Gender:" CssClass="form-label"></asp:Label>
                <div style="margin-top: 5px;">
                    <asp:RadioButton ID="rbMale" runat="server" GroupName="Gender" Text="Male" />
                    <asp:RadioButton ID="rbFemale" runat="server" GroupName="Gender" Text="Female" />
                    <asp:RadioButton ID="rbOther" runat="server" GroupName="Gender" Text="Other" />
                </div>
            </div>
        </div>
        
        <div class="form-section">
            <h3>Contact Information</h3>
            
            <div class="form-row">
                <asp:Label ID="lblEmail" runat="server" Text="Email Address: *" CssClass="form-label" AssociatedControlID="txtEmail"></asp:Label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-input" MaxLength="100"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" 
                    ControlToValidate="txtEmail" 
                    ErrorMessage="Email Address is required" 
                    Text="*" 
                    CssClass="error-message">
                </asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator ID="revEmail" runat="server" 
                    ControlToValidate="txtEmail" 
                    ErrorMessage="Please enter a valid email address" 
                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" 
                    Text="*" 
                    CssClass="error-message">
                </asp:RegularExpressionValidator>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblPhone" runat="server" Text="Phone Number:" CssClass="form-label" AssociatedControlID="txtPhone"></asp:Label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-input" MaxLength="20" placeholder="(555) 123-4567"></asp:TextBox>
                <asp:RegularExpressionValidator ID="revPhone" runat="server" 
                    ControlToValidate="txtPhone" 
                    ErrorMessage="Please enter a valid phone number" 
                    ValidationExpression="^[\(\)\-\s\d]+$" 
                    Text="*" 
                    CssClass="error-message">
                </asp:RegularExpressionValidator>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblAddress" runat="server" Text="Street Address:" CssClass="form-label" AssociatedControlID="txtAddress"></asp:Label>
                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-input" MaxLength="200"></asp:TextBox>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblCity" runat="server" Text="City:" CssClass="form-label" AssociatedControlID="txtCity"></asp:Label>
                <asp:TextBox ID="txtCity" runat="server" CssClass="form-input" MaxLength="50" style="width: 48%; display: inline-block;"></asp:TextBox>
                
                <asp:Label ID="lblState" runat="server" Text="State:" CssClass="form-label" AssociatedControlID="ddlState" style="margin-left: 4%;"></asp:Label>
                <asp:DropDownList ID="ddlState" runat="server" CssClass="form-input" style="width: 48%; display: inline-block;">
                    <asp:ListItem Value="" Text="-- Select State --"></asp:ListItem>
                    <asp:ListItem Value="AL" Text="Alabama"></asp:ListItem>
                    <asp:ListItem Value="AK" Text="Alaska"></asp:ListItem>
                    <asp:ListItem Value="AZ" Text="Arizona"></asp:ListItem>
                    <asp:ListItem Value="AR" Text="Arkansas"></asp:ListItem>
                    <asp:ListItem Value="CA" Text="California"></asp:ListItem>
                    <asp:ListItem Value="CO" Text="Colorado"></asp:ListItem>
                    <asp:ListItem Value="CT" Text="Connecticut"></asp:ListItem>
                    <asp:ListItem Value="DE" Text="Delaware"></asp:ListItem>
                    <asp:ListItem Value="FL" Text="Florida"></asp:ListItem>
                    <asp:ListItem Value="GA" Text="Georgia"></asp:ListItem>
                    <asp:ListItem Value="HI" Text="Hawaii"></asp:ListItem>
                    <asp:ListItem Value="ID" Text="Idaho"></asp:ListItem>
                    <asp:ListItem Value="IL" Text="Illinois"></asp:ListItem>
                    <asp:ListItem Value="IN" Text="Indiana"></asp:ListItem>
                    <asp:ListItem Value="IA" Text="Iowa"></asp:ListItem>
                    <asp:ListItem Value="KS" Text="Kansas"></asp:ListItem>
                    <asp:ListItem Value="KY" Text="Kentucky"></asp:ListItem>
                    <asp:ListItem Value="LA" Text="Louisiana"></asp:ListItem>
                    <asp:ListItem Value="ME" Text="Maine"></asp:ListItem>
                    <asp:ListItem Value="MD" Text="Maryland"></asp:ListItem>
                    <asp:ListItem Value="MA" Text="Massachusetts"></asp:ListItem>
                    <asp:ListItem Value="MI" Text="Michigan"></asp:ListItem>
                    <asp:ListItem Value="MN" Text="Minnesota"></asp:ListItem>
                    <asp:ListItem Value="MS" Text="Mississippi"></asp:ListItem>
                    <asp:ListItem Value="MO" Text="Missouri"></asp:ListItem>
                    <asp:ListItem Value="MT" Text="Montana"></asp:ListItem>
                    <asp:ListItem Value="NE" Text="Nebraska"></asp:ListItem>
                    <asp:ListItem Value="NV" Text="Nevada"></asp:ListItem>
                    <asp:ListItem Value="NH" Text="New Hampshire"></asp:ListItem>
                    <asp:ListItem Value="NJ" Text="New Jersey"></asp:ListItem>
                    <asp:ListItem Value="NM" Text="New Mexico"></asp:ListItem>
                    <asp:ListItem Value="NY" Text="New York"></asp:ListItem>
                    <asp:ListItem Value="NC" Text="North Carolina"></asp:ListItem>
                    <asp:ListItem Value="ND" Text="North Dakota"></asp:ListItem>
                    <asp:ListItem Value="OH" Text="Ohio"></asp:ListItem>
                    <asp:ListItem Value="OK" Text="Oklahoma"></asp:ListItem>
                    <asp:ListItem Value="OR" Text="Oregon"></asp:ListItem>
                    <asp:ListItem Value="PA" Text="Pennsylvania"></asp:ListItem>
                    <asp:ListItem Value="RI" Text="Rhode Island"></asp:ListItem>
                    <asp:ListItem Value="SC" Text="South Carolina"></asp:ListItem>
                    <asp:ListItem Value="SD" Text="South Dakota"></asp:ListItem>
                    <asp:ListItem Value="TN" Text="Tennessee"></asp:ListItem>
                    <asp:ListItem Value="TX" Text="Texas"></asp:ListItem>
                    <asp:ListItem Value="UT" Text="Utah"></asp:ListItem>
                    <asp:ListItem Value="VT" Text="Vermont"></asp:ListItem>
                    <asp:ListItem Value="VA" Text="Virginia"></asp:ListItem>
                    <asp:ListItem Value="WA" Text="Washington"></asp:ListItem>
                    <asp:ListItem Value="WV" Text="West Virginia"></asp:ListItem>
                    <asp:ListItem Value="WI" Text="Wisconsin"></asp:ListItem>
                    <asp:ListItem Value="WY" Text="Wyoming"></asp:ListItem>
                </asp:DropDownList>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblZipCode" runat="server" Text="ZIP Code:" CssClass="form-label" AssociatedControlID="txtZipCode"></asp:Label>
                <asp:TextBox ID="txtZipCode" runat="server" CssClass="form-input" MaxLength="10" style="width: 150px;"></asp:TextBox>
                <asp:RegularExpressionValidator ID="revZipCode" runat="server" 
                    ControlToValidate="txtZipCode" 
                    ErrorMessage="Please enter a valid ZIP code (12345 or 12345-6789)" 
                    ValidationExpression="^\d{5}(-\d{4})?$" 
                    Text="*" 
                    CssClass="error-message">
                </asp:RegularExpressionValidator>
            </div>
        </div>
        
        <div class="form-section">
            <h3>Account Information</h3>
            
            <div class="form-row">
                <asp:Label ID="lblUsername" runat="server" Text="Username: *" CssClass="form-label" AssociatedControlID="txtUsername"></asp:Label>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-input" MaxLength="20"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvUsername" runat="server" 
                    ControlToValidate="txtUsername" 
                    ErrorMessage="Username is required" 
                    Text="*" 
                    CssClass="error-message">
                </asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator ID="revUsername" runat="server" 
                    ControlToValidate="txtUsername" 
                    ErrorMessage="Username must be 3-20 characters and contain only letters, numbers, and underscores" 
                    ValidationExpression="^[a-zA-Z0-9_]{3,20}$" 
                    Text="*" 
                    CssClass="error-message">
                </asp:RegularExpressionValidator>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblPassword" runat="server" Text="Password: *" CssClass="form-label" AssociatedControlID="txtPassword"></asp:Label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-input" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server" 
                    ControlToValidate="txtPassword" 
                    ErrorMessage="Password is required" 
                    Text="*" 
                    CssClass="error-message">
                </asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator ID="revPassword" runat="server" 
                    ControlToValidate="txtPassword" 
                    ErrorMessage="Password must be at least 6 characters long" 
                    ValidationExpression=".{6,}" 
                    Text="*" 
                    CssClass="error-message">
                </asp:RegularExpressionValidator>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblConfirmPassword" runat="server" Text="Confirm Password: *" CssClass="form-label" AssociatedControlID="txtConfirmPassword"></asp:Label>
                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="form-input" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" 
                    ControlToValidate="txtConfirmPassword" 
                    ErrorMessage="Please confirm your password" 
                    Text="*" 
                    CssClass="error-message">
                </asp:RequiredFieldValidator>
                <asp:CompareValidator ID="cvConfirmPassword" runat="server" 
                    ControlToValidate="txtConfirmPassword" 
                    ControlToCompare="txtPassword" 
                    ErrorMessage="Passwords do not match" 
                    Text="*" 
                    CssClass="error-message">
                </asp:CompareValidator>
            </div>
        </div>
        
        <div class="form-section">
            <h3>Preferences</h3>
            
            <div class="form-row">
                <asp:Label ID="lblNewsletterSubscription" runat="server" Text="Newsletter Subscriptions:" CssClass="form-label"></asp:Label>
                <div style="margin-top: 5px;">
                    <asp:CheckBox ID="chkTechNews" runat="server" Text="Technology News" />
                    <br />
                    <asp:CheckBox ID="chkProductUpdates" runat="server" Text="Product Updates" />
                    <br />
                    <asp:CheckBox ID="chkPromotions" runat="server" Text="Special Promotions" />
                </div>
            </div>
            
            <div class="form-row">
                <asp:Label ID="lblContactMethod" runat="server" Text="Preferred Contact Method:" CssClass="form-label"></asp:Label>
                <div style="margin-top: 5px;">
                    <asp:RadioButton ID="rbContactEmail" runat="server" GroupName="ContactMethod" Text="Email" Checked="true" />
                    <br />
                    <asp:RadioButton ID="rbContactPhone" runat="server" GroupName="ContactMethod" Text="Phone" />
                    <br />
                    <asp:RadioButton ID="rbContactMail" runat="server" GroupName="ContactMethod" Text="Postal Mail" />
                </div>
            </div>
        </div>
        
        <div class="form-section">
            <div class="form-row">
                <asp:CheckBox ID="chkTermsOfService" runat="server" Text="I agree to the Terms of Service and Privacy Policy" />
                <div id="chkTermsError" class="error-message" style="display:none;">You must agree to the Terms of Service</div>
            </div>
            
            <div class="form-row text-center">
                <asp:Button ID="btnRegister" runat="server" Text="Register Account" CssClass="btn"  OnClientClick="return validateRegistrationForm();" />
                <asp:Button ID="btnClear" runat="server" Text="Clear Form" CssClass="btn btn-secondary"  CausesValidation="false" OnClientClick="return confirm('Are you sure you want to clear all fields?');" />
            </div>
            
            <div class="form-row text-center">
                <asp:Label ID="lblRegistrationMessage" runat="server" CssClass="success-message" Visible="false"></asp:Label>
            </div>
        </div>
    </div>
    
    <script type="text/javascript">
        function validateRegistrationForm() {
            var firstName = document.getElementById('<%= txtFirstName.ClientID %>').value;
            var lastName = document.getElementById('<%= txtLastName.ClientID %>').value;
            var email = document.getElementById('<%= txtEmail.ClientID %>').value;
            var username = document.getElementById('<%= txtUsername.ClientID %>').value;
            var password = document.getElementById('<%= txtPassword.ClientID %>').value;
            var confirmPassword = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
            var termsAccepted = document.getElementById('<%= chkTermsOfService.ClientID %>').checked;
            var errorDiv = document.getElementById('chkTermsError');
            
            // Hide error message first
            errorDiv.style.display = 'none';
            
            if (firstName == '' || lastName == '' || email == '' || username == '' || password == '') {
                alert('Please fill in all required fields.');
                return false;
            }
            
            if (password != confirmPassword) {
                alert('Passwords do not match.');
                return false;
            }
            
            if (!termsAccepted) {
                errorDiv.style.display = 'block';
                alert('You must agree to the Terms of Service.');
                return false;
            }
            
            return confirm('Are you sure you want to submit this registration?');
        }
        
        function checkUsernameAvailability() {
            var username = document.getElementById('<%= txtUsername.ClientID %>').value;
            if (username.length >= 3) {
                alert('Checking username availability: ' + username);
            }
        }
    </script>
</asp:Content>