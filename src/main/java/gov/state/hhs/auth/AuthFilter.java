package gov.state.hhs.auth;

import jakarta.inject.Inject;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Servlet filter that guards all /staff/* pages.
 * Unauthenticated requests are redirected to the login page.
 */
@WebFilter("/staff/*")
public class AuthFilter implements Filter {

    @Inject
    private SessionBean sessionBean;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        if (sessionBean.isLoggedIn()) {
            chain.doFilter(request, response);
        } else {
            String contextPath = req.getContextPath();
            resp.sendRedirect(contextPath + "/login.xhtml");
        }
    }
}
