var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => Results.Ok(new { status = "ok", service = "DotNetApp" }));
app.MapGet("/health", () => Results.Ok("healthy"));

app.Run();
