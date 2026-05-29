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

    public int getFailedAttempts(String email, String ipAddress, AuthTypes actionType, int minute) {
        String sql = """
            SELECT attempts 
            FROM security_attempts 
            WHERE target_email = :email 
              AND ip_address = :ip 
              AND action_type = :action
              AND last_attempt > NOW() - INTERVAL :minute MINUTE
            """;
        return jdbi.withHandle(handle -> handle.createQuery(sql)
                .bind("email", email)
                .bind("ip", ipAddress)
                .bind("action", actionType.name())
                .bind("minute", minute)
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

    public int countRegisterAttemptsByIp(String ipAddress, int hour) {
        String sql = """
        SELECT SUM(attempts) 
        FROM security_attempts 
        WHERE ip_address = :ip 
          AND action_type = :action
          AND last_attempt > NOW() - INTERVAL :hour HOUR
        """;

        return jdbi.withHandle(handle -> handle.createQuery(sql)
                .bind("ip", ipAddress)
                .bind("action", AuthTypes.REGISTER.name())
                .bind("hour", hour)
                .mapTo(Integer.class)
                .findFirst()
                .orElse(0));
    }
}
