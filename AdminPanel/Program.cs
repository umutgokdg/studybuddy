using Kinde.Api.Models.Configuration;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.EntityFrameworkCore;
using MongoDB.Driver;
using StudyBuddySAP.DataAccess;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);



        builder.Services.AddControllersWithViews();

        builder.Services.AddHttpContextAccessor();      

       
        var database = new MongoClient(builder.Configuration.GetConnectionString("MongoDBConnection")).GetDatabase("StuddyBuddyDB");

        builder.Services.AddDbContext<StuddyBuddyDBContext>(options =>
        {
            options.UseMongoDB(database.Client, database.DatabaseNamespace.DatabaseName);
        });
        
        builder.Services.AddRazorPages();
        builder.Services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = Microsoft.AspNetCore.Authentication.Cookies.CookieAuthenticationDefaults.AuthenticationScheme;
            options.DefaultScheme = Microsoft.AspNetCore.Authentication.Cookies.CookieAuthenticationDefaults.AuthenticationScheme;

        }).AddCookie(options =>
        {
            options.LoginPath = builder.Configuration.GetSection("Paths").GetSection("LoginPath").Value;
            options.LogoutPath = builder.Configuration.GetSection("Paths").GetSection("LogoutPath").Value;
        });

        builder.Services.AddAuthorization(options =>
        {
            options.AddPolicy("RequireAdminRole", policy => policy.RequireRole("Admin"));            
        });

        var app = builder.Build();

        // Configure the HTTP request pipeline.
        if (!app.Environment.IsDevelopment())
        {
            app.UseExceptionHandler("/Home/Error");
            app.UseHsts();
        }
        

        app.UseHttpsRedirection();
        app.UseStaticFiles();

        app.UseRouting();

        app.UseAuthentication();
        app.UseAuthorization();

        app.MapRazorPages();

        app.MapControllerRoute(
            name: "default",
            pattern: "{controller=Home}/{action=Index}/{id?}");

        app.Run();
    }

}


