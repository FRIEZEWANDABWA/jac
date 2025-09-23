# walkers.jac - Core security walkers for Digital Bastion

walker auth_walker {
    has user user_ref;
    has str session_token;

    can verify_credentials(username: str, password_hash: str) {
        # Find user by username
        target_user = [user(username == username)];
        
        if target_user {
            user_node = target_user[0];
            if user_node.password_hash == password_hash {
                if user_node.mfa_enabled {
                    print("MFA required for " + user_node.username);
                    return {"status": "mfa_required", "user_id": user_node.username};
                } else {
                    self.user_ref = user_node;
                    user_node.last_login = "2024-01-01T00:00:00Z";  # Update timestamp
                    print("Auth success for " + user_node.username);
                    return {"status": "success", "user": user_node.username, "roles": user_node.roles};
                }
            } else {
                print("Auth failed: invalid password");
                return {"status": "failed", "reason": "invalid_credentials"};
            }
        } else {
            print("Auth failed: user not found");
            return {"status": "failed", "reason": "user_not_found"};
        }
    }
}

walker access_control_walker {
    has user actor;
    has str resource;
    has str action;

    can check_permission() {
        if not self.actor {
            return {"allowed": false, "reason": "no_actor"};
        }

        # Find applicable policies
        matching_policies = [policy(resource == self.resource and active == true)];
        
        for pol in matching_policies {
            # Check if user role matches policy
            for role in self.actor.roles {
                if role in pol.allowed_roles and self.action in pol.actions {
                    print("Access granted: " + self.actor.username + " -> " + self.resource);
                    return {"allowed": true, "policy": pol.name};
                }
            }
        }
        
        print("Access denied: " + self.actor.username + " -> " + self.resource);
        # Spawn incident for unauthorized access
        spawn incident_walker(
            offender=self.actor,
            target_resource=self.resource,
            reason="unauthorized_access_attempt"
        );
        return {"allowed": false, "reason": "insufficient_permissions"};
    }
}

walker network_scanner {
    has list target_devices;
    has float risk_threshold = 0.7;

    can scan_devices() {
        results = [];
        
        for device in self.target_devices {
            # Simulate network scan
            risk_factors = 0;
            
            # Check for high-risk ports
            high_risk_ports = [22, 23, 135, 445, 3389];
            for port in device.open_ports {
                if port in high_risk_ports {
                    risk_factors += 1;
                }
            }
            
            # Calculate risk score
            new_risk = min(risk_factors * 0.2, 1.0);
            device.update_risk(new_risk);
            
            if new_risk > self.risk_threshold {
                # Create security incident
                spawn incident_walker(
                    target_device=device,
                    reason="high_risk_device_detected",
                    severity="medium"
                );
            }
            
            results.append({
                "device": device.hostname,
                "risk_score": new_risk,
                "open_ports": device.open_ports
            });
        }
        
        return results;
    }
}

walker incident_walker {
    has user offender;
    has device target_device;
    has str target_resource;
    has str reason;
    has str severity = "medium";

    can create_incident() {
        # Create new incident node
        new_incident = incident(
            severity=self.severity,
            reason=self.reason,
            timestamp="2024-01-01T00:00:00Z",
            status="open",
            evidence=[]
        );

        # Connect relationships
        if self.offender {
            self.offender ++violates++ new_incident;
            self.offender.recv_alert("Security incident created: " + self.reason);
        }
        
        if self.target_device {
            self.target_device ++affects++ new_incident;
        }

        print("Incident created: " + new_incident.reason + " [" + new_incident.severity + "]");
        return {"incident_id": new_incident.reason, "status": "created"};
    }
}

walker threat_detection_walker {
    has list log_sources;
    has dict threat_patterns;

    can analyze_logs() {
        threats_found = [];
        
        # Get recent log entries
        recent_logs = [log_entry(level in ["warning", "error", "critical"])];
        
        for log in recent_logs {
            # Simple pattern matching for threats
            if "failed login" in log.message.lower() {
                threats_found.append({
                    "type": "brute_force_attempt",
                    "source": log.source,
                    "timestamp": log.timestamp
                });
            }
            
            if "malware" in log.message.lower() or "virus" in log.message.lower() {
                threats_found.append({
                    "type": "malware_detected",
                    "source": log.source,
                    "timestamp": log.timestamp
                });
                
                # Create high-priority incident
                spawn incident_walker(
                    reason="malware_detection",
                    severity="high"
                );
            }
        }
        
        return threats_found;
    }
}