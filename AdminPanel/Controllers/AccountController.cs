using Microsoft.AspNetCore.Mvc;
using Polly;
using StudyBuddySAP.Models;

namespace StudyBuddySAP.Controllers
{
    public class AccountController : BaseController<AccountController>
    {
        

        [HttpPost]
        public IActionResult Login(LoginViewModel model)
        {

            if (ModelState.IsValid)
            {
                // Check if the username exists in the database
                var user = Context.Users.FirstOrDefault(i => i.email == model.Email);

                if (user != null && BCrypt.Net.BCrypt.Verify(model.Password, user.hashed_pwd))
                {
                    return RedirectToAction("Index", "Groups");
                }
                else
                {
                    ModelState.AddModelError("", "Invalid username or password.");
                }
            }

            // If the ModelState is invalid or authentication fails, return to the login view
            return RedirectToAction("Index", "Home", model);
        }
    }
}
