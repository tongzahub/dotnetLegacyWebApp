<%@ Page Title="About Us" Language="C#" MasterPageFile="~/Site.Master" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div style="max-width: 800px; margin: 0 auto;">
        <h2>About Our Legacy Web Application</h2>
        
        <div class="form-section">
            <h3>Application Overview</h3>
            <p>This is a demonstration of a legacy ASP.NET Web Forms application built for .NET Framework 3.5. 
            The application showcases classic web development techniques and controls that were commonly used 
            in enterprise applications during the 2008-2012 era.</p>
            
            <p>The application demonstrates:</p>
            <ul>
                <li>Master Page layout with consistent navigation</li>
                <li>Server-side controls (TextBox, Button, GridView, etc.)</li>
                <li>Form validation using ASP.NET validators</li>
                <li>Data presentation with GridView including paging and sorting</li>
                <li>Cross-browser compatibility for Internet Explorer 8+</li>
                <li>Basic responsive design within .NET 3.5 constraints</li>
            </ul>
        </div>
        
        <div class="form-section">
            <h3>Technical Specifications</h3>
            <table class="data-grid" style="width: 100%;">
                <tr>
                    <th style="width: 30%;">Technology</th>
                    <th>Version/Details</th>
                </tr>
                <tr>
                    <td><strong>.NET Framework</strong></td>
                    <td>3.5 SP1</td>
                </tr>
                <tr>
                    <td><strong>ASP.NET</strong></td>
                    <td>Web Forms 3.5</td>
                </tr>
                <tr>
                    <td><strong>Programming Language</strong></td>
                    <td>C# 3.0</td>
                </tr>
                <tr>
                    <td><strong>Web Server</strong></td>
                    <td>IIS 7.0 or higher</td>
                </tr>
                <tr>
                    <td><strong>Browser Support</strong></td>
                    <td>Internet Explorer 8+, Firefox 3.5+, Chrome 4+, Safari 4+</td>
                </tr>
                <tr>
                    <td><strong>CSS Version</strong></td>
                    <td>CSS 2.1 with selective CSS3 features</td>
                </tr>
                <tr>
                    <td><strong>JavaScript</strong></td>
                    <td>ECMAScript 3 compatible</td>
                </tr>
            </table>
        </div>
        
        <div class="form-section">
            <h3>Features Demonstrated</h3>
            
            <h4>Home Page (Default.aspx)</h4>
            <ul>
                <li>Contact form with various input types</li>
                <li>Client-side and server-side validation</li>
                <li>File upload functionality</li>
                <li>Real-time server information display</li>
            </ul>
            
            <h4>Data Grid Page (DataGrid.aspx)</h4>
            <ul>
                <li>GridView with custom formatting</li>
                <li>Sorting and paging functionality</li>
                <li>Search and filtering capabilities</li>
                <li>Custom pager template</li>
                <li>Row command handling</li>
                <li>Summary statistics display</li>
            </ul>
            
            <h4>User Form Page (UserForm.aspx)</h4>
            <ul>
                <li>Comprehensive registration form</li>
                <li>Multiple validation controls</li>
                <li>State dropdown with all US states</li>
                <li>Password confirmation validation</li>
                <li>Terms of service acceptance</li>
            </ul>
        </div>
        
        <div class="form-section">
            <h3>Legacy Web Development Practices</h3>
            <p>This application follows the development patterns and practices that were standard during the .NET 3.5 era:</p>
            
            <div style="display: table; width: 100%; margin-top: 15px;">
                <div style="display: table-cell; width: 50%; padding-right: 20px; vertical-align: top;">
                    <h4>Backend Patterns</h4>
                    <ul>
                        <li>Page lifecycle event handling</li>
                        <li>ViewState for maintaining control state</li>
                        <li>Postback event model</li>
                        <li>Server control event handling</li>
                        <li>Code-behind file separation</li>
                    </ul>
                </div>
                <div style="display: table-cell; width: 50%; vertical-align: top;">
                    <h4>Frontend Patterns</h4>
                    <ul>
                        <li>Table-based and CSS layout</li>
                        <li>Inline JavaScript for interactivity</li>
                        <li>CSS 2.1 for styling</li>
                        <li>Cross-browser compatibility code</li>
                        <li>Progressive enhancement techniques</li>
                    </ul>
                </div>
            </div>
        </div>
        
        <div class="form-section">
            <h3>Browser Compatibility Notes</h3>
            <p>This application is designed to work with older browsers that were common during the .NET 3.5 timeframe:</p>
            
            <div class="form-row">
                <strong>Internet Explorer 8 Support:</strong>
                <ul>
                    <li>HTML5 shim included for semantic elements</li>
                    <li>CSS expressions avoided</li>
                    <li>JavaScript limited to ECMAScript 3</li>
                    <li>Box-sizing polyfill considerations</li>
                </ul>
            </div>
            
            <div class="form-row">
                <strong>Responsive Design Limitations:</strong>
                <ul>
                    <li>Media queries used sparingly (IE9+ feature)</li>
                    <li>Fixed-width layout with flexible content</li>
                    <li>JavaScript-based menu toggling for mobile</li>
                    <li>Table-based data presentation</li>
                </ul>
            </div>
        </div>
        
        <div class="form-section">
            <h3>Contact Information</h3>
            <div style="background-color: #ecf0f1; padding: 15px; border-radius: 5px;">
                <p><strong>Development Team:</strong> Legacy Web Solutions</p>
                <p><strong>Application Version:</strong> 1.0.0</p>
                <p><strong>Build Date:</strong> <asp:Label ID="lblBuildDate" runat="server" Text="<%# DateTime.Now.ToString('MMMM dd, yyyy') %>"></asp:Label></p>
                <p><strong>Support Contact:</strong> support@legacywebapp.com</p>
                <p><strong>Documentation:</strong> Available in the project wiki</p>
            </div>
        </div>
        
        <div class="form-section text-center">
            <asp:Button ID="btnBackToHome" runat="server" Text="Back to Home Page" CssClass="btn" PostBackUrl="~/Default.aspx" />
            <asp:Button ID="btnViewSource" runat="server" Text="View Page Source" CssClass="btn btn-secondary" OnClientClick="viewPageSource(); return false;" />
        </div>
    </div>
    
    <script type="text/javascript">
        function viewPageSource() {
            if (typeof window.external != 'undefined' && window.external.ViewPageSource) {
                // IE specific method
                window.external.ViewPageSource();
            } else {
                // For other browsers, show an alert with instructions
                alert('To view page source:\\n\\n' + 
                      'Internet Explorer: Press Ctrl+U\\n' + 
                      'Firefox: Press Ctrl+U\\n' + 
                      'Chrome: Press Ctrl+U\\n' + 
                      'Safari: Press Alt+Cmd+U');
            }
        }
        
        // Display current browser information
        function showBrowserInfo() {
            var browserInfo = 'Browser Information:\\n';
            browserInfo += 'User Agent: ' + navigator.userAgent + '\\n';
            browserInfo += 'Platform: ' + navigator.platform + '\\n';
            browserInfo += 'Language: ' + navigator.language + '\\n';
            browserInfo += 'Screen Resolution: ' + screen.width + 'x' + screen.height;
            
            alert(browserInfo);
        }
        
        // Page load initialization
        window.onload = function() {
            // Add a subtle animation effect for supported browsers
            var sections = document.getElementsByClassName('form-section');
            for (var i = 0; i < sections.length; i++) {
                sections[i].style.opacity = '0.8';
                sections[i].onmouseover = function() { this.style.opacity = '1'; };
                sections[i].onmouseout = function() { this.style.opacity = '0.8'; };
            }
        };
    </script>
</asp:Content>