using BasicAuth.WebApi.Auth;
using BasicAuth.WebApi.Data;
using BasicAuth.WebApi.Interfaces;
using BasicAuth.WebApi.Repositories;
using BasicAuth.WebApi.Services;
using Microsoft.AspNetCore.Authentication;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddTransient<UsersService>();

// Registro del repositorio a utilizar
builder.Services.AddSingleton<IUsersRepository, InMemoryUsersRepository>();

//https://dotnetthoughts.net/implementing-basic-authentication-in-minimal-webapi/
builder.Services.AddAuthentication("BasicAuthentication")
                .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>
                ("BasicAuthentication", null);
builder.Services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();

var app = builder.Build();

//Seed data
using (var scope = app.Services.CreateScope())
{
    var usersService = scope.ServiceProvider.GetRequiredService<UsersService>();
    DataSeeder.SeedUsers(usersService);
}

// Configure the HTTP request pipeline.
//if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();




