using System.Collections.Concurrent;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// Serve the /public folder as the website root
var publicPath = Path.Combine(app.Environment.ContentRootPath, "public");

app.UseDefaultFiles(new DefaultFilesOptions
{
    FileProvider = new PhysicalFileProvider(publicPath)
});

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(publicPath)
});

// In-memory store (acceptable for demo; DB can be added later)
var users = new ConcurrentBag<UserDto>();

app.MapPost("/register", (RegisterRequest req) =>
{
    // Step 4: Server-side validation + processing
    if (string.IsNullOrWhiteSpace(req.Username))
        return Results.BadRequest(new { error = "Username required (server)." });

    if (string.IsNullOrWhiteSpace(req.Email))
        return Results.BadRequest(new { error = "Email required (server)." });

    if (string.IsNullOrWhiteSpace(req.Password) || req.Password.Length < 6)
        return Results.BadRequest(new { error = "Password must be at least 6 characters (server)." });

    // Demo note: do not store plaintext passwords in real systems.
    var user = new UserDto(req.Username.Trim(), req.Email.Trim());
    users.Add(user);

    return Results.Ok(new { user });
});

app.Run();

record RegisterRequest(string Username, string Email, string Password);
record UserDto(string Username, string Email);
