# abilities.jac - Reusable abilities for Digital Bastion

# Logging ability for audit trails
can log_action(action: str, details: dict) {
    timestamp = "2024-01-01T00:00:00Z";  # Use proper timestamp function
    log_message = f"Action: {action}, Details: {details}, Time: {timestamp}";
    print(f"[AUDIT] {log_message}");
    
    # Create log entry node
    audit_log = log_entry(
        source="system",
        message=log_message,
        timestamp=timestamp,
        level="info",
        metadata=details
    );
}

# Email notification ability
can send_email_alert(recipient: str, subject: str, message: str) {
    print(f"EMAIL ALERT to {recipient}: {subject}");
    print(f"Message: {message}");
    # Integration point for actual email service
    return {"status": "sent", "recipient": recipient};
}

# WhatsApp notification ability  
can send_whatsapp_alert(phone: str, message: str) {
    print(f"WHATSAPP ALERT to {phone}: {message}");
    # Integration point for WhatsApp API
    return {"status": "sent", "phone": phone};
}

# Risk assessment ability
can calculate_device_risk(device_node: device) -> float {
    risk_score = 0.0;
    
    # OS-based risk
    if "windows" in device_node.os.lower() {
        risk_score += 0.1;
    }
    
    # Port-based risk
    high_risk_ports = [22, 23, 135, 445, 3389, 5900];
    for port in device_node.open_ports {
        if port in high_risk_ports {
            risk_score += 0.15;
        }
    }
    
    # Vulnerability-based risk
    services = [service(++runs++ device_node)];
    for svc in services {
        risk_score += len(svc.vulnerabilities) * 0.1;
    }
    
    return min(risk_score, 1.0);
}

# Policy validation ability
can validate_policy(policy_node: policy) -> bool {
    required_fields = ["name", "resource", "allowed_roles", "actions"];
    
    for field in required_fields {
        if not hasattr(policy_node, field) {
            print(f"Policy validation failed: missing {field}");
            return false;
        }
    }
    
    if len(policy_node.allowed_roles) == 0 {
        print("Policy validation failed: no roles specified");
        return false;
    }
    
    if len(policy_node.actions) == 0 {
        print("Policy validation failed: no actions specified");
        return false;
    }
    
    return true;
}

# Network zone security check
can check_zone_security(zone: network_zone) -> dict {
    security_score = 1.0;
    issues = [];
    
    # Check devices in zone
    zone_devices = [device(++belongs_to++ zone)];
    
    for dev in zone_devices {
        if dev.risk_score > 0.7 {
            security_score -= 0.2;
            issues.append(f"High-risk device: {dev.hostname}");
        }
    }
    
    # Check for unauthorized services
    zone_services = [service(++belongs_to++ zone)];
    for svc in zone_services {
        if svc.name not in zone.allowed_services {
            security_score -= 0.1;
            issues.append(f"Unauthorized service: {svc.name}");
        }
    }
    
    return {
        "zone": zone.name,
        "security_score": max(security_score, 0.0),
        "issues": issues
    };
}

# Incident escalation ability
can escalate_incident(incident_node: incident) {
    if incident_node.severity == "critical" {
        # Notify all admins
        admin_users = [user("admin" in roles)];
        for admin in admin_users {
            admin.recv_alert(f"CRITICAL INCIDENT: {incident_node.reason}");
            send_email_alert(
                admin.email,
                "Critical Security Incident",
                f"Incident: {incident_node.reason}\nSeverity: {incident_node.severity}"
            );
        }
    }
    
    # Update incident status
    incident_node.status = "escalated";
    log_action("incident_escalated", {
        "incident_id": incident_node.reason,
        "severity": incident_node.severity
    });
}