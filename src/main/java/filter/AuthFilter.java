package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(servletNames = { "UserController" })
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse rep = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
        if (isLoggedIn) {
            chain.doFilter(request, response);
        } else {
            handleUnauthenticated(req, rep);
        }
    }

    private void handleUnauthenticated(HttpServletRequest req, HttpServletResponse rep) throws IOException {
        String requestWith = req.getHeader("X-Requested-With");
        if ("XMLHttpRequest".equals(requestWith)) {
            rep.setStatus(401);
            return;
        } else {
            String uri = req.getRequestURI();
            String query = req.getQueryString();
            String redirectUrl = uri + (query != null ? "?" + query : "");
            rep.sendRedirect(req.getContextPath() + "/login?redirect=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
        }

    }
}
