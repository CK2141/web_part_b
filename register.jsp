<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // ====== Server-side processing (same file) ======
    // If this is an AJAX POST request, process and return a plain-text response (or JSON if you prefer).
    String method = request.getMethod();

    // Identify AJAX request via header set in fetch()
    String requestedWith = request.getHeader("X-Requested-With");
    boolean isAjax = (requestedWith != null && requestedWith.equalsIgnoreCase("XMLHttpRequest"));

    if ("POST".equalsIgnoreCase(method) && isAjax) {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Basic server-side validation (never rely only on client-side checks)
        if (username == null || username.trim().length() < 3) {
            out.print("Error: Username must be at least 3 characters.");
            return;
        }
        if (email == null || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            out.print("Error: Please enter a valid email address.");
            return;
        }
        if (password == null || password.length() < 8) {
            out.print("Error: Password must be at least 8 characters.");
            return;
        }

        // Demonstration-only: we are NOT storing passwords or using a database here.
        // In a real application: hash password (e.g., BCrypt) + store in database + handle duplicates, etc.
        out.print("Registration successful for '" + username + "'. A confirmation could be sent to: " + email);
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Dynamic Registration (Single JSP File)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 24px; line-height: 1.4; }
        .container { max-width: 520px; }
        label { display: block; margin-top: 12px; }
        input { width: 100%; padding: 10px; margin-top: 6px; box-sizing: border-box; }
        button { margin-top: 14px; padding: 10px 14px; cursor: pointer; }
        .msg { margin-top: 14px; padding: 12px; border: 1px solid #ccc; }
        .error { border-color: #c00; }
        .ok { border-color: #0a7; }
        small { color: #555; display: block; margin-top: 8px; }
        .hint { background: #f6f6f6; padding: 10px; border: 1px solid #ddd; margin-top: 14px; }
    </style>
</head>
<body>
<div class="container">
    <h1>User Registration</h1>

    <p class="hint">
        This is a single-file dynamic JSP application: HTML form + JavaScript validation + AJAX submission + server-side JSP processing.
        The form submits asynchronously and updates the page without a reload.
    </p>

    <!-- ====== Step 1: Basic HTML form ====== -->
    <form id="registerForm" autocomplete="on">
        <label for="username">Username</label>
        <input type="text" id="username" name="username" required minlength="3" placeholder="e.g., testuser123" />

        <label for="email">Email address</label>
        <input type="email" id="email" name="email" required placeholder="e.g., testuser123@example.com" />

        <label for="password">Password</label>
        <input type="password" id="password" name="password" required minlength="8" placeholder="Minimum 8 characters" />

        <button type="submit">Register</button>

        <small>
            Client-side rules: username ≥ 3 chars, email valid, password ≥ 8 chars. Server re-checks the same rules.
        </small>
    </form>

    <!-- ====== Step 5: Dynamic update area ====== -->
    <div id="message" class="msg" style="display:none;"></div>
</div>

<script>
/* ====== Step 2: Client-side validation (JavaScript) ====== */
function isValidEmail(email) {
    // Simple email pattern for demonstration (server also validates)
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function showMessage(text, ok) {
    const box = document.getElementById("message");
    box.style.display = "block";
    box.textContent = text;
    box.classList.remove("error", "ok");
    box.classList.add(ok ? "ok" : "error");
}

document.getElementById("registerForm").addEventListener("submit", function (e) {
    e.preventDefault();

    const username = document.getElementById("username").value.trim();
    const email = document.getElementById("email").value.trim();
    const password = document.getElementById("password").value;

    if (username.length < 3) {
        showMessage("Client validation error: Username must be at least 3 characters.", false);
        return;
    }
    if (!isValidEmail(email)) {
        showMessage("Client validation error: Please enter a valid email address.", false);
        return;
    }
    if (password.length < 8) {
        showMessage("Client validation error: Password must be at least 8 characters.", false);
        return;
    }

    /* ====== Step 3: AJAX submission (no page reload) ====== */
    const formData = new FormData();
    formData.append("username", username);
    formData.append("email", email);
    formData.append("password", password);

    fetch("register.jsp", {
        method: "POST",
        headers: { "X-Requested-With": "XMLHttpRequest" },
        body: formData
    })
    .then(res => res.text())
    .then(text => {
        // ====== Step 5: Update UI dynamically ======
        const ok = !text.startsWith("Error:");
        showMessage(text, ok);

        if (ok) {
            // Optional UX: clear password only (common practice)
            document.getElementById("password").value = "";
        }
    })
    .catch(() => {
        showMessage("Network/server error: registration request failed.", false);
    });
});
</script>
</body>
</html>
