package model;

import org.jdbi.v3.core.mapper.reflect.ColumnName;

import java.sql.Timestamp;

public class SecurityAttempt {
    @ColumnName("id")
    private Integer id;

    @ColumnName("ip_address")
    private String ipAddress;

    @ColumnName("target_email")
    private String targetEmail;

    @ColumnName("action_type")
    private AuthTypes actionType;

    @ColumnName("attempts")
    private int attempts;

    @ColumnName("last_attempt")
    private Timestamp lastAttempt;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public int getAttempts() {
        return attempts;
    }

    public void setAttempts(int attempts) {
        this.attempts = attempts;
    }

    public Timestamp getLastAttempt() {
        return lastAttempt;
    }

    public void setLastAttempt(Timestamp lastAttempt) {
        this.lastAttempt = lastAttempt;
    }

    public String getTargetEmail() {
        return targetEmail;
    }

    public void setTargetEmail(String targetEmail) {
        this.targetEmail = targetEmail;
    }

    public AuthTypes getActionType() {
        return actionType;
    }

    public void setActionType(AuthTypes actionType) {
        this.actionType = actionType;
    }
}
