package model;

import org.jdbi.v3.core.mapper.reflect.ColumnName;

public class Permission {
    @ColumnName("id")
    private int id;
    @ColumnName("permission_key")
    private String permissionKey;
    @ColumnName("description")
    private String description;

    public Permission() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getPermissionKey() {
        return permissionKey;
    }

    public void setPermissionKey(String permissionKey) {
        this.permissionKey = permissionKey;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
