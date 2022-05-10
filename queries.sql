/*    • Найти все отечественные аналитические CASE-средства, отсортировав их в порядке увеличения рейтинга.*/
SELECT 
	CASE_tool.name, 
	AVG(Review.rating)
FROM
	CASE_tool
	JOIN Type ON CASE_tool.type_id = Type.type_id
	JOIN Review ON CASE_tool.case_tool_id = Review.case_tool_id
	JOIN Developer ON CASE_tool.developer_id = Developer.developer_id
	JOIN Country ON Developer.country_id = Country.country_id
WHERE
	Country.name = 'Российская Федерация'
	AND Type.name = 'Средство анализа'
GROUP BY
	CASE_tool.name
ORDER BY
	AVG(Review.rating) DESC
	
/*    • Найти все CASE-средства, работающие на Mac или Windows, обладающие определенной функцией и имеющие рейтинг не ниже 3. Отсортируйте по цене.*/
WITH selected_tools AS (
    SELECT 
        CASE_tool.case_tool_id, 
        AVG(Review.rating) AS avg_rating, 
        GROUP_CONCAT(DISTINCT Platform.name) AS platforms
    FROM
        CASE_tool
        JOIN Review ON CASE_tool.case_tool_id = Review.case_tool_id
        JOIN CASE_tools_features ON CASE_tool.case_tool_id = CASE_tools_features.case_tool_id
        JOIN Feature ON Feature.feature_id = CASE_tools_features.feature_id
        JOIN CASE_tools_platforms ON CASE_tool.case_tool_id = CASE_tools_platforms.case_tool_id
        JOIN Platform ON Platform.platform_id = CASE_tools_platforms.platform_id
    WHERE
        Feature.name = 'economy-value'
        AND (
            Platform.name = 'Windows'
            OR
            Platform.name = 'Mac OS'
        )
    GROUP BY
        CASE_tool.case_tool_id
    HAVING
        AVG(Review.rating) >= 3
)
SELECT
    name,
    price,
    avg_rating,
    platforms
FROM 
    selected_tools 
    JOIN CASE_tool ON selected_tools.case_tool_id = CASE_tool.case_tool_id
ORDER BY
    price
	

/*    • Провести сравнение двух средств: вывести функции, которыми обладает одна, но не обладает другая, а также разницу в цене. */
SET @system1 = 'databasebackend' COLLATE utf8mb4_0900_ai_ci;
SET @system2 = 'cloud_interface' COLLATE utf8mb4_0900_ai_ci;

WITH system1_features AS
(
    SELECT 
    	CASE_tool.case_tool_id,
    	Feature.name AS feature_name
    FROM 
    	CASE_tool
        JOIN CASE_tools_features ON CASE_tool.case_tool_id = CASE_tools_features.case_tool_id
        JOIN Feature ON Feature.feature_id = CASE_tools_features.feature_id
    WHERE 
    	CASE_tool.name = @system1
),
system2_features AS
(
    SELECT 
    	CASE_tool.case_tool_id,
    	Feature.name AS feature_name
    FROM 
    	CASE_tool
        JOIN CASE_tools_features ON CASE_tool.case_tool_id = CASE_tools_features.case_tool_id
        JOIN Feature ON Feature.feature_id = CASE_tools_features.feature_id
    WHERE 
    	CASE_tool.name = @system2
),
common_features AS
(
    SELECT
    	GROUP_CONCAT(DISTINCT feature_name) AS common_feature
    FROM
        system1_features
        JOIN system2_features
    USING(feature_name)
),
system1_unique_features AS
(
	SELECT 
    	GROUP_CONCAT(feature_name)
    FROM 
    	system1_features 
    	LEFT JOIN system2_features USING(feature_name)
    WHERE system2_features.feature_name IS NULL
    GROUP BY 
    	system1_features.case_tool_id
),
system2_unique_features AS
(
	SELECT 
    	GROUP_CONCAT(feature_name)
    FROM 
    	system2_features 
    	LEFT JOIN system1_features USING(feature_name)
    WHERE system1_features.feature_name IS NULL
    GROUP BY 
    	system2_features.case_tool_id
)
SELECT 
	@system1,
    @system2,
	(SELECT * FROM common_features) AS common_features,
	(SELECT * FROM system1_unique_features) AS system1_unique_features,
    (SELECT * FROM system2_unique_features) AS system2_unique_features,
    (SELECT price FROM CASE_tool WHERE name = @system1) - (SELECT price FROM CASE_tool WHERE name = @system2) AS price_difference_1_minus_2

/*    • На какой платформе больше всего CASE-средств с открытым исходным кодом? */
WITH platform_opensource_count AS
(
    SELECT
        platform_id,
        COUNT(case_tool_id) AS opensource_count
    FROM
        CASE_tool
        JOIN CASE_tools_platforms USING(case_tool_id)
        JOIN Platform USING(platform_id)
    WHERE
        source_code_url IS NOT NULL
    GROUP BY
        platform_id
)
SELECT
    platform_id,
    name AS platform_name,
    opensource_count
FROM
    platform_opensource_count
    JOIN Platform USING(platform_id)
ORDER BY
    opensource_count DESC
LIMIT 1
    
/*    • Для заданного пользователя подсчитать, сколько он оставил отзывов к системам каждого типа, и какую среднюю оценку для этого типа он поставил. */
WITH user_review_counts AS (
	SELECT 
        type_id,
        COUNT(review_id) AS review_count,
        AVG(rating) AS avg_rating
    FROM
        MyUser
        JOIN Review USING(user_id)
        JOIN CASE_tool USING(case_tool_id)
        JOIN Type USING(type_id)
    WHERE
        MyUser.username = ' iulii49'
    GROUP BY
        type_id
)
SELECT
	type_id,
    name,
    review_count,
    avg_rating
FROM 
	user_review_counts
    JOIN Type USING(type_id)
ORDER BY
    type_id
    
/*    • Подсчитать, сколько систем заданного типа было выпущено за каждый год, какова их средняя цена и оценка. */
WITH case_tool_ratings AS
(
    SELECT
        case_tool_id,
        AVG(rating) AS rating
    FROM 
        CASE_tool
        JOIN Review USING(case_tool_id)
    	JOIN Type USING(type_id)
    WHERE
    	Type.name = 'Средство разработки'
    GROUP BY
        case_tool_id
)
SELECT
	YEAR(release_date) as release_year,
	COUNT(case_tool_id),
	AVG(price),
    AVG(rating)
FROM
	CASE_tool
    JOIN case_tool_ratings USING(case_tool_id)
GROUP BY
	YEAR(release_date)
ORDER BY
	release_year

/*    • Найти накрутчиков отзывов – пользователей, которые опубликовали более 20 отзывов за последние 3 дня.*/
SELECT
	user_id,
    COUNT(review_id) AS review_count,
    AVG(rating) AS avg_rating
FROM
	MyUser
    JOIN Review USING(user_id)
WHERE
	publication_date > NOW() - INTERVAL 3 DAY
GROUP BY
	user_id
HAVING
	review_count > 20
	
