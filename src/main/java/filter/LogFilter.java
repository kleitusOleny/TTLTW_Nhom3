package filter;

import org.slf4j.MDC;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import java.io.IOException;
import java.util.UUID;

@WebFilter("/*") // Quét tất cả mọi request đi qua
public class LogFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        String traceId = UUID.randomUUID().toString().substring(0, 4);
        MDC.put("trace_id", "req-" + traceId);
        try {
            // Cho phép request đi tiếp vào Controller/JSP
            chain.doFilter(request, response);
        } finally {
            // Giải phóng bộ nhớ khi request kết thúc (Bắt buộc)
            MDC.remove("trace_id");
        }
    }
}