CREATE TABLE IF NOT EXISTS Country (
	country_id INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(50) NOT NULL,
	
	PRIMARY KEY (country_id)
);

CREATE TABLE IF NOT EXISTS Developer (
	developer_id INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(100) NOT NULL,
	webpage VARCHAR(2048) NOT NULL,
	country_id INT,
	
	PRIMARY KEY (developer_id),
	
	FOREIGN KEY (country_id)
		REFERENCES Country(country_id)
		ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Type (
	type_id INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(50) NOT NULL,
	description TEXT,
	
	PRIMARY KEY (type_id)
);

CREATE TABLE IF NOT EXISTS CASE_tool (
	case_tool_id INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(100) NOT NULL,
	description TEXT,
	type_id INT NOT NULL,
	developer_id INT NOT NULL,
	release_date DATE NOT NULL,
	last_update_date DATE NOT NULL,
	price INT NOT NULL,
	purchase_url VARCHAR(2048) NOT NULL,
	source_code_url VARCHAR(2048),
	
	PRIMARY KEY (case_tool_id),
	
	FOREIGN KEY (type_id)
		REFERENCES Type(type_id)
		ON DELETE RESTRICT,
		
	FOREIGN KEY (developer_id)
		REFERENCES Developer(developer_id)
		ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Feature (
	feature_id INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(50) NOT NULL,
	description TEXT,
	
	PRIMARY KEY (feature_id)
);

CREATE TABLE IF NOT EXISTS CASE_tools_features (
	case_tool_id INT NOT NULL,
	feature_id INT NOT NULL,
	
	PRIMARY KEY (case_tool_id, feature_id),
	
	FOREIGN KEY (case_tool_id)
		REFERENCES CASE_tool(case_tool_id)
		ON DELETE RESTRICT,
		
	FOREIGN KEY (feature_id)
		REFERENCES Feature(feature_id)
		ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Platform (
	platform_id INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(50) NOT NULL,
	
	PRIMARY KEY (platform_id)
);

CREATE TABLE IF NOT EXISTS CASE_tools_platforms (
	case_tool_id INT NOT NULL,
	platform_id INT NOT NULL,
	
	PRIMARY KEY (case_tool_id, platform_id),
	
	FOREIGN KEY (case_tool_id)
		REFERENCES CASE_tool(case_tool_id)
		ON DELETE RESTRICT,
		
	FOREIGN KEY (platform_id)
		REFERENCES Platform(platform_id)
		ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Role (
	role_id INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(50) NOT NULL,
	
	PRIMARY KEY (role_id)
);

CREATE TABLE IF NOT EXISTS MyUser (
	user_id INT NOT NULL AUTO_INCREMENT,
	email VARCHAR(256) NOT NULL,
	username VARCHAR(100) NOT NULL,
	password CHAR(64) NOT NULL, /* Hash of the password */
	last_login_date DATE NOT NULL,
	role_id INT NOT NULL,
	developer_id INT,
	
	PRIMARY KEY (type_id),
	
	FOREIGN KEY (role_id)
		REFERENCES Role(role_id)
		ON DELETE RESTRICT,
		
	FOREIGN KEY (developer_id)
		REFERENCES Developer(developer_id)
		ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Review (
	review_id INT NOT NULL AUTO_INCREMENT,
	case_tool_id INT NOT NULL,
	user_id INT NOT NULL,
	publication_date DATE NOT NULL,
	review_text TEXT NOT NULL,
	rating TINYINT NOT NULL,
	
	
	PRIMARY KEY (review_id),
	
	FOREIGN KEY (case_tool_id)
		REFERENCES CASE_tool(case_tool_id)
		ON DELETE CASCADE,
		
	FOREIGN KEY (user_id)
		REFERENCES MyUser(user_id)
		ON DELETE CASCADE
);

