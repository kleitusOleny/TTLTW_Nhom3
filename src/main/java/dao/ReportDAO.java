package dao;

import java.util.List;
import java.util.Map;

public class ReportDAO extends ADAO {

    // 1. Doanh thu theo ngày (30 ngày qua)
    public List<Map<String, Object>> getRevenueByDay() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT CONCAT(DATE(create_at), '') as time_label, SUM(total_price) as revenue " +
                                "FROM orders " +
                                "WHERE is_delete IS NULL AND create_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) " +
                                "GROUP BY DATE(create_at) " +
                                "ORDER BY DATE(create_at) ASC")
                        .mapToMap()
                        .list()
        );
    }

    // 2. Doanh thu theo tháng (12 tháng qua)
    public List<Map<String, Object>> getRevenueByMonth() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT DATE_FORMAT(create_at, '%Y-%m') as time_label, SUM(total_price) as revenue " +
                                "FROM orders " +
                                "WHERE is_delete IS NULL AND create_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH) " +
                                "GROUP BY DATE_FORMAT(create_at, '%Y-%m') " +
                                "ORDER BY DATE_FORMAT(create_at, '%Y-%m') ASC")
                        .mapToMap()
                        .list()
        );
    }

    // 3. Doanh thu theo quý (8 quý qua)
    public List<Map<String, Object>> getRevenueByQuarter() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT CONCAT(YEAR(create_at), '-Q', QUARTER(create_at)) as time_label, SUM(total_price) as revenue " +
                                "FROM orders " +
                                "WHERE is_delete IS NULL AND create_at >= DATE_SUB(NOW(), INTERVAL 24 MONTH) " +
                                "GROUP BY YEAR(create_at), QUARTER(create_at) " +
                                "ORDER BY YEAR(create_at) ASC, QUARTER(create_at) ASC")
                        .mapToMap()
                        .list()
        );
    }

    // 4. Doanh thu theo năm (tất cả các năm)
    public List<Map<String, Object>> getRevenueByYear() {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT CONCAT(YEAR(create_at), '') as time_label, SUM(total_price) as revenue " +
                                "FROM orders " +
                                "WHERE is_delete IS NULL " +
                                "GROUP BY YEAR(create_at) " +
                                "ORDER BY YEAR(create_at) ASC")
                        .mapToMap()
                        .list()
        );
    }

    // 5. Top 10 sản phẩm bán chạy nhất
    public List<Map<String, Object>> getBestSellingProducts(int limit) {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT p.id, p.product_name as product_name, SUM(oi.quantity) as total_sold, SUM(oi.quantity * oi.unit_price) as total_revenue " +
                                "FROM order_items oi " +
                                "JOIN orders o ON oi.order_id = o.id " +
                                "JOIN products p ON oi.product_id = p.id " +
                                "WHERE o.is_delete IS NULL " +
                                "GROUP BY p.id, p.product_name " +
                                "ORDER BY total_sold DESC " +
                                "LIMIT :limit")
                        .bind("limit", limit)
                        .mapToMap()
                        .list()
        );
    }

    // 6. Sản phẩm không bán được trong N tháng qua
    public List<Map<String, Object>> getUnsoldProducts(int months) {
        return jdbi.withHandle(handle ->
                handle.createQuery("SELECT p.id, p.product_name, p.price, p.quantity " +
                                "FROM products p " +
                                "WHERE p.is_delete = 0 " +
                                "  AND p.id NOT IN ( " +
                                "      SELECT DISTINCT oi.product_id " +
                                "      FROM order_items oi " +
                                "      JOIN orders o ON oi.order_id = o.id " +
                                "      WHERE o.is_delete IS NULL AND o.create_at >= DATE_SUB(NOW(), INTERVAL :months MONTH) " +
                                "  ) " +
                                "ORDER BY p.product_name ASC")
                        .bind("months", months)
                        .mapToMap()
                        .list()
        );
    }
}
