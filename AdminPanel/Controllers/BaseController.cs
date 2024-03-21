using Microsoft.AspNetCore.Mvc;
using StudyBuddySAP.DataAccess;

namespace StudyBuddySAP.Controllers
{
    public class BaseController<T> : Controller where T : BaseController<T>
    {
        private StuddyBuddyDBContext? _context;
        protected StuddyBuddyDBContext Context => _context ??= HttpContext.RequestServices.GetRequiredService<StuddyBuddyDBContext>();


    }
}
