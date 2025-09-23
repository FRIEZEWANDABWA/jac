# data.jac - Node & edge definitions for Digital Bastion cybersecurity platform

node user {
    has str username;
    has str email;
    has str password_hash;
    has list roles;            # ["admin", "operator", "analyst"]
    has bool mfa_enabled = false;
    has str created_at;
    has str last_login;

    can recv_alert(alert_msg: str) {
        print("Alert for " + this.username + ": " + alert_msg);
        # Integration hook for email/WhatsApp notifications
    }
}

node device {
    has str hostname;
    has str ip_addr;
    has str mac_addr;
    has str os;
    has float risk_score = 0.0;
    has str last_seen;
    has str status = "active";  # active, inactive, compromised
    has list open_ports;

    can update_risk(new_risk: float) {
        this.risk_score = new_risk;
        if (new_risk > 0.8) {
            print("HIGH RISK DEVICE: " + this.hostname);
        }
    }
}

node service {
    has str name;
    has list ports;
    has bool enabled = true;
    has str version;
    has list vulnerabilities;
}

node policy {
    has str name;
    has str resource;
    has list allowed_roles;
    has list actions;
    has str condition;
    has bool active = true;
}

node incident {
    has str severity;  # low, medium, high, critical
    has str reason;
    has str timestamp;
    has str status = "open";  # open, investigating, resolved
    has list evidence;
}

node network_zone {
    has str name;
    has str subnet;
    has str trust_level;  # dmz, internal, restricted
    has list allowed_services;
}

node log_entry {
    has str source;
    has str message;
    has str timestamp;
    has str level;  # info, warning, error, critical
    has dict metadata;
}

# Edge types for relationships
edge owns;
edge runs;
edge controls;
edge connected_to;
edge violates;
edge affects;
edge belongs_to;