<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Andromeda - Login & Register</title>
  
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />
  
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      display: flex;
      height: 100vh;
      background-color: #ffffff;
      overflow: hidden;
    }

    .left {
      width: 60%;
      height: 100vh;
      background-color: #222222; 
      background-image: url('newCar.avif'); 
      background-repeat: no-repeat;
      background-position: center center;
      background-size: cover;
      position: relative;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .right {
      width: 40%;
      height: 100vh;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      padding: 40px;
      overflow-y: auto;
    }

    .left::before {
      content: '';
      position: absolute;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(0, 0, 0, 0.3);
    }

    .brand-title {
      position: relative;
      color: #ffffff;
      font-size: 3rem;
      font-weight: 700;
      letter-spacing: 0.3em;
      text-transform: uppercase;
      z-index: 2;
      text-shadow: 0 4px 12px rgba(0,0,0,0.5);
      margin-left: 0.3em; 
    }

    .form-container {
      width: 100%;
      max-width: 400px;
      animation: fadeIn 0.4s ease-out;
    }

    h1 {
      font-size: 1.75rem;
      font-weight: 700;
      color: #000000;
      margin-bottom: 8px;
    }

    .subtitle {
      font-size: 0.875rem;
      color: #666666;
      margin-bottom: 32px;
      line-height: 1.5;
    }

    form {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }

    .input-group {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }

    .input-row {
      display: flex;
      gap: 16px;
    }
    
    .input-row .input-group {
      flex: 1;
    }

    label {
      font-size: 0.8rem;
      font-weight: 600;
      color: #333333;
    }

    input[type="text"],
    input[type="password"],
    input[type="email"],
    select {
      width: 100%;
      padding: 12px 14px;
      background-color: #f7f7f7;
      border: 1px solid #d1d1d1;
      border-radius: 6px;
      font-size: 0.9rem;
      color: #000000;
      font-family: inherit;
      transition: all 0.2s ease;
    }

    input::placeholder {
      color: #999999;
    }

    input:focus, select:focus {
      border-color: #000000;
      background-color: #ffffff;
      outline: none;
      box-shadow: 0 0 0 2px rgba(0, 0, 0, 0.1);
    }

    .password-wrapper {
      position: relative;
      display: flex;
      align-items: center;
      width: 100%;
    }
    
    .password-wrapper input {
      padding-right: 40px !important; 
    }

    .peek-btn {
      position: absolute;
      right: 12px;
      background: transparent;
      border: none;
      color: #666666;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.1rem;
      padding: 0;
      transition: color 0.2s ease;
    }

    .peek-btn:hover {
      color: #000000;
    }

    input[type="submit"] {
      width: 100%;
      padding: 14px;
      margin-top: 8px;
      background-color: #000000;
      color: #ffffff;
      border: none;
      border-radius: 6px;
      font-size: 0.95rem;
      font-weight: 600;
      cursor: pointer;
      transition: background-color 0.2s ease;
    }

    input[type="submit"]:hover:not(:disabled) {
      background-color: #333333;
    }

    input[type="submit"]:disabled {
      background-color: #cccccc;
      color: #666666;
      cursor: not-allowed;
    }

    .toggle-link {
      font-size: 0.875rem;
      color: #666666;
      margin-top: 24px;
      text-align: center;
    }

    .toggle-link a {
      color: #000000;
      font-weight: 600;
      text-decoration: none;
      margin-left: 4px;
      border-bottom: 1px solid transparent;
      transition: border-color 0.2s;
    }

    .toggle-link a:hover {
      border-color: #000000;
    }

    .message-box {
      width: 100%;
      max-width: 400px;
      padding: 12px 16px;
      margin-bottom: 20px;
      border-radius: 6px;
      font-size: 0.9rem;
      font-weight: 500;
      display: none;
    }

    .message-success {
      background-color: #f0fdf4;
      color: #15803d;
      border: 1px solid #bbf7d0;
    }

    .message-error {
      background-color: #fef2f2;
      color: #b91c1c;
      border: 1px solid #fecaca;
    }

    input[readonly] {
      background-color: #eeeeee;
      color: #777777;
      cursor: not-allowed;
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(10px); }
      to { opacity: 1; transform: translateY(0); }
    }

    @media (max-width: 900px) {
      body { flex-direction: column; }
      .left { width: 100%; height: 250px; flex: none; }
      .right { width: 100%; height: auto; flex: 1; padding: 24px; justify-content: flex-start; }
      .brand-title { font-size: 2rem; }
    }
  </style>
</head>
<body>
  
  <div class="left">
    <div class="brand-title">ANDROMEDA</div>
  </div>

  <div class="right">
    <div id="messageBox" class="message-box"></div>
    
    <div class="form-container" id="loginContainer">
      <h1>Welcome Back!</h1>
      <p class="subtitle">Sign in to continue to Andromeda Workspace Portal.</p>
      
      <form id="loginForm">
        <div class="input-group">
          <label for="loginUsername">Username</label>
          <input type="text" id="loginUsername" name="username" placeholder="Enter your username" required autocomplete="username" />
        </div>
        
        <div class="input-group">
          <label for="loginPassword">Password</label>
          <div class="password-wrapper">
            <input type="password" id="loginPassword" name="password" placeholder="Enter your password" required />
            <button type="button" class="peek-btn" title="Toggle password visibility">
              <i class="bi bi-eye"></i>
            </button>
          </div>
        </div>
        
        <input type="submit" value="Login" />
      </form>
      
      <div class="toggle-link">
        Don't have an account? 
        <a href="#" onclick="toggleForm('register'); return false;">Sign up</a>
      </div>
    </div>


    <div class="form-container" id="registerContainer" style="display:none;">
      <h1>Create your Account</h1>
      <p class="subtitle">Enter your details to register.</p>
      
      <form id="registerForm">
        
        <div class="input-row">
          <div class="input-group">
            <label for="firstname">First Name</label>
            <input type="text" id="firstname" name="firstname" placeholder="John" required />
          </div>
          <div class="input-group">
            <label for="lastname">Last Name</label>
            <input type="text" id="lastname" name="lastname" placeholder="Doe" required />
          </div>
        </div>

        <div class="input-group">
          <label for="email">Email</label>
          <input type="email" id="email" name="email" placeholder="name@company.com" required />
        </div>

        <div class="input-group">
          <label for="regUsername">Username</label>
          <input type="text" id="regUsername" name="username" placeholder="Choose a username" required />
        </div>

        <div class="input-row">
          <div class="input-group">
            <label for="regPassword">Password</label>
            <div class="password-wrapper">
              <input type="password" id="regPassword" name="password" placeholder="Min 8 characters" required />
              <button type="button" class="peek-btn" title="Toggle password visibility">
                <i class="bi bi-eye"></i>
              </button>
            </div>
          </div>
          <div class="input-group">
            <label for="confirmPassword">Confirm</label>
            <div class="password-wrapper">
              <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Repeat password" required />
              <button type="button" class="peek-btn" title="Toggle password visibility">
                <i class="bi bi-eye"></i>
              </button>
            </div>
          </div>
        </div>

        <div class="input-row">
          <div class="input-group">
            <label for="country">Country</label>
            <select id="country" name="country" required>
              <option value="" disabled selected>Select Country</option>
              <option value="Australia">Australia</option>
              <option value="Canada">Canada</option>
              <option value="Germany">Germany</option>
              <option value="India">India</option>
              <option value="United States">United States</option>
            </select>
          </div>
          
          <div class="input-group">
            <label for="accessDisplay">Access Level</label>
            <input type="text" id="accessDisplay" value="Reader" readonly />
            <input type="hidden" name="Access" value="Reader" />
          </div>
        </div>

        <input type="submit" value="Get Started" />
      </form>
      
      <div class="toggle-link">
        Already have an account? 
        <a href="#" onclick="toggleForm('login'); return false;">Sign in here</a>
      </div>
    </div>
  </div>

  <script>
    const BASIC_URL = '<%= request.getContextPath() %>';
    
    $(document).ready(() => {

      $('.peek-btn').on('click', function() {
        const $input = $(this).siblings('input');
        const $icon = $(this).find('i');
        
        if ($input.attr('type') === 'password') {
          $input.attr('type', 'text');
          $icon.removeClass('bi-eye').addClass('bi-eye-slash');
        } else {
          $input.attr('type', 'password');
          $icon.removeClass('bi-eye-slash').addClass('bi-eye');
        }
      });

      function toggleForm(formType) {
        if (formType === 'login') {
          $('#registerContainer').hide();
          $('#loginContainer').fadeIn();
        } else {
          $('#loginContainer').hide();
          $('#registerContainer').fadeIn();
        }
      }

      function disableForm(formSelector, disabled) {
        $(`${formSelector} :input`).prop('disabled', disabled);
      }

      function showMessage(message, type = 'success', duration = 3500) {
        const box = $('#messageBox');
        box.removeClass('message-success message-error');
        box.addClass(type === 'success' ? 'message-success' : 'message-error');
        box.text(message).fadeIn();
        setTimeout(() => {
          box.fadeOut();
        }, duration);
      }

      $('#loginForm').on('submit', function (e) {
        e.preventDefault();
        const username = $('#loginUsername').val().trim();
        const password = $('#loginPassword').val().trim();
        
        if (!username || !password) {
          showMessage('Please enter both username and password.', 'error');
          return;
        }
        
        disableForm('#loginForm', true);
        
        $.ajax({
          url: BASIC_URL + '/api/myresource/login',
          type: 'POST',
          contentType: 'application/x-www-form-urlencoded',
          data: $.param({
            Username: username,
            Password: password
          }),
          success: (response) => {
            const res = typeof response === 'string' ? JSON.parse(response) : response;
            if (res.Status === "Success") {
              showMessage('Login successful!', 'success');
              sessionStorage.setItem('loggedInUser', JSON.stringify({
                username: res.Username,
                email: res.Email,
                firstname: res.Firstname,
                lastname: res.Lastname,
                access: res.Access 
              }));
              setTimeout(() => {
                window.location.href = 'amxNavigatorHome.jsp';
              }, 1000);
            } else {
              showMessage('Login failed: ' + res.Message, 'error');
            }
          },
          error: (xhr) => {
            try {
              const err = JSON.parse(xhr.responseText);
              showMessage('Login error: ' + err.Message, 'error');
            } catch {
              showMessage('Login error: Server error.', 'error');
            }
          },
          complete: () => {
            disableForm('#loginForm', false);
          }
        });
      });

      $('#registerForm').on('submit', function (e) {
        e.preventDefault();
        const email = $('#email').val().trim();
        const username = $('#regUsername').val().trim();
        const firstname = $('#firstname').val().trim();
        const lastname = $('#lastname').val().trim();
        const password = $('#regPassword').val().trim();
        const confirmPassword = $('#confirmPassword').val().trim();
        const country = $('#country').val();
        const access = $('#registerForm input[name="Access"]').val();

        if (!email || !username || !firstname || !lastname || !password || !confirmPassword || !country) {
          showMessage('All fields are required.', 'error');
          return;
        }

        if (password !== confirmPassword) {
          showMessage('Passwords do not match.', 'error');
          return;
        }

        disableForm('#registerForm', true);

        $.ajax({
          url: BASIC_URL + '/api/myresource/register',
          type: 'POST',
          contentType: 'application/x-www-form-urlencoded',
          data: $.param({
            Email: email,
            Username: username,
            Firstname: firstname,
            Lastname: lastname,
            Password: password,
            ConfirmPassword: confirmPassword,
            Country: country,
            Access: access
          }),
          success: (response) => {
            const res = typeof response === 'string' ? JSON.parse(response) : response;
            if (res.Status === "Success") {
              showMessage('Registration successful!', 'success');
              $('#registerForm')[0].reset();
              setTimeout(() => {
                toggleForm('login');
              }, 2000);
            } else {
              showMessage('Registration failed: ' + res.Message, 'error');
            }
          },
          error: (xhr) => {
            try {
              const err = JSON.parse(xhr.responseText);
              showMessage('Registration error: ' + err.Message, 'error');
            } catch {
              showMessage('Registration error: Server error.', 'error');
            }
          },
          complete: () => {
            disableForm('#registerForm', false);
          }
        });
      });

      window.toggleForm = toggleForm;
    });
  </script>
</body>
</html>