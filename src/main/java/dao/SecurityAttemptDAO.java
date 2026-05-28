package dao;

import model.AuthTypes;

public class SecurityAttemptDAO extends ADAO {
    public boolean increaseAttempt(String email, String ipAddress, AuthTypes actionType) {
        String sql = """
            INSERT INTO security_attempts (target_email, ip_address, action_type, attempts) 
            VALUES (:email, :ip, :action, 1)
            ON DUPLICATE KEY UPDATE attempts = attempts + 1
            """;
        return jdbi.withHandle(handle -> handle.createUpdate(sql)
                .bind("email", email)
                .bind("ip", ipAddress)
                .bind("action", actionType.name())
                .execute() > 0);
    }

    public int getFailedAttempts(String email, String ipAddress, AuthTypes actionType) {
        String sql = """
            SELECT attempts 
            FROM security_attempts 
            WHERE target_email = :email 
              AND ip_address = :ip 
              AND action_type = :action
              AND last_attempt > NOW() - INTERVAL 15 MINUTE
            """;
        return jdbi.withHandle(handle -> handle.createQuery(sql)
                .bind("email", email)
                .bind("ip", ipAddress)
                .bind("action", actionType.name())
                .mapTo(Integer.class)
                .findFirst()
                .orElse(0));
    }

    public void resetAttempts(String email, String ipAddress, AuthTypes actionType) {
        String sql = """
            DELETE FROM security_attempts 
            WHERE target_email = :email 
              AND ip_address = :ip 
              AND action_type = :action
            """;
        jdbi.withHandle(handle -> handle.createUpdate(sql)
                .bind("email", email)
                .bind("ip", ipAddress)
                .bind("action", actionType.name())
                .execute());
    }
}
