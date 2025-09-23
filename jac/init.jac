# init.jac - Bootstrap Digital Bastion security platform

with entry {
    print("Initializing Digital Bastion Security Platform...");
    
    # Create default admin user
    admin_user = user(
        username="admin",
        email="admin@digitalbastion.com",
        password_hash="$2b$12$hashed_password_here",
        roles=["admin", "operator", "analyst"],
        mfa_enabled=true,
        created_at="2024-01-01T00:00:00Z",
        last_login=""
    );
    
    # Create default security policies
    admin_policy = policy(
        name="admin_full_access",
        resource="*",
        allowed_roles=["admin"],
        actions=["read", "write", "delete", "execute"],
        condition="always",
        active=true
    );
    
    operator_policy = policy(
        name="operator_monitoring",
        resource="monitoring",
        allowed_roles=["operator", "admin"],
        actions=["read", "write"],
        condition="business_hours",
        active=true
    );
    
    analyst_policy = policy(
        name="analyst_readonly",
        resource="logs",
        allowed_roles=["analyst", "operator", "admin"],
        actions=["read"],
        condition="always",
        active=true
    );
    
    # Create network zones
    dmz_zone = network_zone(
        name="DMZ",
        subnet="192.168.1.0/24",
        trust_level="dmz",
        allowed_services=["web", "dns", "mail"]
    );
    
    internal_zone = network_zone(
        name="Internal",
        subnet="10.0.0.0/16",
        trust_level="internal",
        allowed_services=["file_share", "database", "application"]
    );
    
    restricted_zone = network_zone(
        name="Restricted",
        subnet="172.16.0.0/24",
        trust_level="restricted",
        allowed_services=["backup", "management"]
    );
    
    # Create sample devices
    web_server = device(
        hostname="web-01",
        ip_addr="192.168.1.10",
        mac_addr="00:11:22:33:44:55",
        os="Ubuntu 22.04",
        risk_score=0.2,
        last_seen="2024-01-01T00:00:00Z",
        status="active",
        open_ports=[80, 443, 22]
    );
    
    db_server = device(
        hostname="db-01",
        ip_addr="10.0.1.50",
        mac_addr="00:11:22:33:44:66",
        os="CentOS 8",
        risk_score=0.1,
        last_seen="2024-01-01T00:00:00Z",
        status="active",
        open_ports=[3306, 22]
    );
    
    # Create services
    web_service = service(
        name="nginx",
        ports=[80, 443],
        enabled=true,
        version="1.20.1",
        vulnerabilities=[]
    );
    
    db_service = service(
        name="mysql",
        ports=[3306],
        enabled=true,
        version="8.0.28",
        vulnerabilities=["CVE-2023-1234"]
    );
    
    # Connect relationships
    admin_user ++owns++ web_server;
    admin_user ++owns++ db_server;
    
    web_server ++runs++ web_service;
    db_server ++runs++ db_service;
    
    web_server ++belongs_to++ dmz_zone;
    db_server ++belongs_to++ internal_zone;
    
    admin_user ++controls++ web_service;
    admin_user ++controls++ db_service;
    
    print("✓ Created admin user: " + admin_user.username);
    print("✓ Created security policies: 3");
    print("✓ Created network zones: 3");
    print("✓ Created devices: 2");
    print("✓ Created services: 2");
    print("✓ Established relationships");
    
    # Run initial security scan
    print("\nRunning initial security assessment...");
    
    all_devices = [device()];
    scanner = spawn network_scanner(target_devices=all_devices);
    scan_results = scanner.scan_devices();
    
    print("✓ Security scan completed");
    print("Digital Bastion Security Platform initialized successfully!");
    
    # Log initialization
    log_action("platform_initialized", {
        "users": 1,
        "policies": 3,
        "devices": 2,
        "services": 2,
        "zones": 3
    });
}