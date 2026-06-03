package model;

import org.jdbi.v3.core.mapper.reflect.ColumnName;

public class Role {
    @ColumnName("id")
    private int id;
    @ColumnName("role_name")
    private String roleName;
    @ColumnName("description")
    private String description;

    public Role() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
