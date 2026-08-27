CREATE DATABASE IF NOT EXISTS dating_match CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE dating_match;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  user_type ENUM('foreign','korean') NOT NULL,
  nickname VARCHAR(80) NOT NULL,
  bio VARCHAR(500),
  age TINYINT UNSIGNED,
  preferred_area VARCHAR(80),
  match_score DECIMAL(5,2) NOT NULL DEFAULT 0,
  nationality VARCHAR(80) NOT NULL,
  age_range VARCHAR(30) NOT NULL,
  gender VARCHAR(30) NOT NULL,
  visa_type VARCHAR(80),
  photo_url VARCHAR(500),
  matching_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  dietary_preference ENUM('all','halal','vegetarian') NOT NULL DEFAULT 'all',
  location VARCHAR(120),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_users_matching (user_type, matching_enabled, nationality),
  INDEX idx_users_matching_sort (preferred_area, match_score, age)
);

-- Existing installations can run these statements once after the initial schema.
-- ALTER TABLE users ADD COLUMN nickname VARCHAR(80) NOT NULL DEFAULT '미결추 사용자';
-- ALTER TABLE users ADD COLUMN bio VARCHAR(500), ADD COLUMN age TINYINT UNSIGNED, ADD COLUMN preferred_area VARCHAR(80), ADD COLUMN match_score DECIMAL(5,2) NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS places (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  category VARCHAR(80) NOT NULL,
  area VARCHAR(80) NOT NULL,
  description VARCHAR(500),
  cost_min INT UNSIGNED NOT NULL DEFAULT 0,
  cost_max INT UNSIGNED NOT NULL DEFAULT 0,
  indoor BOOLEAN NOT NULL DEFAULT FALSE,
  halal BOOLEAN NOT NULL DEFAULT FALSE,
  vegetarian BOOLEAN NOT NULL DEFAULT FALSE,
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  google_place_id VARCHAR(180) UNIQUE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_places_filter (is_active, area, halal, vegetarian)
);

CREATE TABLE IF NOT EXISTS match_requests (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  requester_id BIGINT UNSIGNED NOT NULL,
  partner_id BIGINT UNSIGNED NOT NULL,
  status ENUM('requested','accepted','rejected','cancelled') NOT NULL DEFAULT 'requested',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_match_request (requester_id, partner_id),
  CONSTRAINT fk_requester FOREIGN KEY (requester_id) REFERENCES users(id),
  CONSTRAINT fk_partner FOREIGN KEY (partner_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  type ENUM('match_request','match_accepted','message') NOT NULL,
  match_request_id BIGINT UNSIGNED,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_notification_request FOREIGN KEY (match_request_id) REFERENCES match_requests(id)
);

CREATE TABLE IF NOT EXISTS conversations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  match_request_id BIGINT UNSIGNED NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_conversation_request FOREIGN KEY (match_request_id) REFERENCES match_requests(id)
);

CREATE TABLE IF NOT EXISTS messages (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  conversation_id BIGINT UNSIGNED NOT NULL,
  sender_id BIGINT UNSIGNED NOT NULL,
  body VARCHAR(1000) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_message_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id),
  CONSTRAINT fk_message_sender FOREIGN KEY (sender_id) REFERENCES users(id),
  INDEX idx_messages_conversation (conversation_id, created_at)
);

CREATE TABLE IF NOT EXISTS place_feedback (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  place_id BIGINT UNSIGNED NOT NULL,
  value ENUM('up','down') NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_place_feedback (user_id, place_id),
  CONSTRAINT fk_feedback_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_feedback_place FOREIGN KEY (place_id) REFERENCES places(id)
);


USE dating_match;

CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  type ENUM('match_request','match_accepted','message') NOT NULL,
  match_request_id BIGINT UNSIGNED,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_notification_request FOREIGN KEY (match_request_id) REFERENCES match_requests(id)
);

CREATE TABLE IF NOT EXISTS conversations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  match_request_id BIGINT UNSIGNED NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_conversation_request FOREIGN KEY (match_request_id) REFERENCES match_requests(id)
);

CREATE TABLE IF NOT EXISTS messages (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  conversation_id BIGINT UNSIGNED NOT NULL,
  sender_id BIGINT UNSIGNED NOT NULL,
  body VARCHAR(1000) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_message_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id),
  CONSTRAINT fk_message_sender FOREIGN KEY (sender_id) REFERENCES users(id),
  INDEX idx_messages_conversation (conversation_id, created_at)
);

USE dating_match;

ALTER TABLE users ADD COLUMN email VARCHAR(190) UNIQUE;
ALTER TABLE users ADD COLUMN password_hash VARCHAR(255) NOT NULL DEFAULT '';


SET NAMES utf8mb4;
USE dating_match;

ALTER TABLE users ADD COLUMN match_target ENUM('foreign','korean') NULL;

ALTER TABLE users MODIFY dietary_preference VARCHAR(30) NULL;
UPDATE users SET dietary_preference = NULL
  WHERE dietary_preference NOT IN ('korean','western','japanese','chinese','southeast_asian','middle_eastern');
ALTER TABLE users MODIFY dietary_preference
  ENUM('korean','western','japanese','chinese','southeast_asian','middle_eastern') NULL;

ALTER TABLE places ADD COLUMN cuisine
  ENUM('korean','western','japanese','chinese','southeast_asian','middle_eastern') NULL;
ALTER TABLE places ADD COLUMN has_parking BOOLEAN NOT NULL DEFAULT FALSE;


SET NAMES utf8mb4;
USE dating_match;

ALTER TABLE places ADD COLUMN place_type ENUM('food','cafe','activity') NULL;


SET NAMES utf8mb4;
USE dating_match;

ALTER TABLE places MODIFY place_type ENUM('food','cafe','activity','culture','shopping') NULL;


SET NAMES utf8mb4;
USE dating_match;

ALTER TABLE users ADD COLUMN birth_date DATE NULL;


SET NAMES utf8mb4;
USE dating_match;

INSERT INTO places (name, category, area, description, cost_min, cost_max, indoor, halal, vegetarian, cuisine, has_parking, place_type, latitude, longitude, google_place_id)
VALUES
('서촌 작은 책방', '동네 책방', '서촌', '오래된 한옥 골목 안에서 취향을 나눠요', 0, 18000, TRUE, TRUE, TRUE, NULL, FALSE, 'culture', 37.5796, 126.9696, 'seed-seochon-bookshop'),
('통인시장 도시락 카페', '전통시장', '서촌', '엽전으로 직접 골라 담는 서울식 점심', 9000, 16000, TRUE, FALSE, TRUE, 'korean', FALSE, 'food', 37.5808, 126.9693, 'seed-tongin-market'),
('서촌 티하우스', '전통찻집', '서촌', '한옥 마당에서 즐기는 전통차와 다과', 7000, 12000, TRUE, FALSE, FALSE, NULL, FALSE, 'cafe', 37.5800, 126.9700, 'seed-seochon-teahouse'),
('서촌 한옥골목 산책', '동네 산책', '서촌', '한옥 지붕 사이로 걷는 조용한 골목길', 0, 5000, FALSE, FALSE, FALSE, NULL, FALSE, 'activity', 37.5802, 126.9705, 'seed-seochon-walk'),
('통인동 소품가게', '소품샵', '서촌', '아기자기한 소품과 문구를 구경해요', 0, 15000, TRUE, FALSE, FALSE, NULL, FALSE, 'shopping', 37.5804, 126.9698, 'seed-tongin-shop'),
('인왕산 초소책방', '뷰 포인트', '부암동', '서울이 내려다보이는 조용한 산책과 따뜻한 차', 8000, 14000, TRUE, TRUE, TRUE, NULL, FALSE, 'cafe', 37.5926, 126.9636, 'seed-inwangsan-bookshop'),
('부암동 백사실계곡 산책', '계곡 산책', '부암동', '도심 속 작은 계곡을 따라 걷는 한적한 숲길', 0, 3000, FALSE, FALSE, FALSE, NULL, FALSE, 'activity', 37.5936, 126.9646, 'seed-buam-baeksasil'),
('부암동 家 家 백반', '가정식 백반', '부암동', '집밥처럼 편안한 계절 반찬으로 채운 한 상', 10000, 16000, TRUE, FALSE, TRUE, 'korean', FALSE, 'food', 37.5921, 126.9652, 'seed-buam-bakban'),
('홍대 벽화 골목', '동네 산책', '홍대', '골목마다 그림을 구경하며 천천히 걷기 좋은 코스', 0, 8000, FALSE, TRUE, TRUE, NULL, FALSE, 'activity', 37.5563, 126.9237, 'seed-hongdae-mural'),
('연남동 브런치 카페', '브런치 카페', '홍대', '경의선숲길 옆에서 여유롭게 즐기는 브런치', 12000, 22000, TRUE, FALSE, TRUE, 'western', TRUE, 'food', 37.5506052, 126.9254349, 'seed-yeonnam-brunch'),
('홍대 쌀국수 골목', '베트남 음식', '홍대', '향긋한 쌀국수와 스프링롤을 함께 먹어요', 8000, 13000, TRUE, FALSE, TRUE, 'southeast_asian', FALSE, 'food', 37.5567, 126.9241, 'seed-hongdae-pho'),
('홍대 디저트 카페', '디저트 카페', '홍대', '아기자기한 디저트와 커피를 함께 즐겨요', 8000, 15000, TRUE, FALSE, FALSE, NULL, FALSE, 'cafe', 37.5559, 126.9231, 'seed-hongdae-dessert'),
('홍대 프리마켓', '플리마켓', '홍대', '주말마다 열리는 수공예 플리마켓 구경하기', 0, 12000, FALSE, FALSE, FALSE, NULL, FALSE, 'shopping', 37.5570, 126.9245, 'seed-hongdae-market'),
('홍대 아트갤러리', '갤러리', '홍대', '신진 작가들의 작품을 함께 감상해요', 5000, 10000, TRUE, FALSE, FALSE, NULL, FALSE, 'culture', 37.5551, 126.9228, 'seed-hongdae-gallery'),
('가로수길 편집숍 거리', '쇼핑 거리', '강남', '나란히 걸으며 구경하기 좋은 편집숍과 팝업스토어', 0, 10000, FALSE, TRUE, TRUE, NULL, FALSE, 'shopping', 37.5202, 127.0229, 'seed-garosugil-shopping'),
('강남 딤섬 맛집', '중식당', '강남', '함께 나눠 먹기 좋은 딤섬 코스', 15000, 28000, TRUE, FALSE, TRUE, 'chinese', FALSE, 'food', 37.4983, 127.0281, 'seed-gangnam-dimsum'),
('강남 루프탑 카페', '루프탑 카페', '강남', '노을과 도심 야경을 함께 볼 수 있는 카페', 10000, 20000, TRUE, FALSE, TRUE, NULL, FALSE, 'cafe', 37.4979, 127.0276, 'seed-gangnam-rooftop'),
('도산공원 산책', '도심 공원', '강남', '나무 그늘 아래를 함께 걷는 도심 속 공원', 0, 4000, FALSE, FALSE, FALSE, NULL, FALSE, 'activity', 37.5237, 127.0369, 'seed-gangnam-park'),
('강남 팝업 전시장', '팝업 전시', '강남', '시즌마다 바뀌는 팝업 전시를 구경해요', 0, 15000, TRUE, FALSE, FALSE, NULL, FALSE, 'culture', 37.4990, 127.0287, 'seed-gangnam-popup'),
('성수동 카페거리', '카페 거리', '성수동', '공장을 개조한 개성 있는 카페들이 모여있는 거리', 8000, 18000, TRUE, FALSE, TRUE, NULL, FALSE, 'cafe', 37.5445, 127.0559, 'seed-seongsu-cafe'),
('서울숲', '도심 공원', '성수동', '함께 걷고 자전거도 탈 수 있는 넓은 공원', 0, 6000, FALSE, TRUE, TRUE, NULL, FALSE, 'activity', 37.5443, 127.0374, 'seed-seoul-forest'),
('성수동 라멘집', '일본식 라멘', '성수동', '진한 돈코츠 육수의 라멘을 함께 즐겨요', 9000, 14000, TRUE, FALSE, FALSE, 'japanese', FALSE, 'food', 37.5449, 127.0562, 'seed-seongsu-ramen'),
('성수동 편집숍 거리', '편집숍 거리', '성수동', '감각적인 편집숍들을 구경하며 걷는 거리', 0, 20000, FALSE, FALSE, FALSE, NULL, FALSE, 'shopping', 37.5441, 127.0563, 'seed-seongsu-shopping'),
('성수동 복합문화공간', '복합문화공간', '성수동', '옛 공장을 개조한 전시 · 공연 공간', 6000, 14000, TRUE, FALSE, FALSE, NULL, FALSE, 'culture', 37.5448, 127.0546, 'seed-seongsu-culture'),
('이태원 세계음식거리', '세계음식 거리', '이태원', '다양한 나라의 음식을 함께 골라 먹기 좋은 거리', 10000, 25000, FALSE, TRUE, TRUE, 'middle_eastern', FALSE, 'food', 37.5346, 126.9947, 'seed-itaewon-food-street'),
('이태원 스페셜티 커피', '스페셜티 커피', '이태원', '향미 좋은 원두로 내린 커피 한 잔', 6000, 11000, FALSE, FALSE, FALSE, NULL, FALSE, 'cafe', 37.5350, 126.9945, 'seed-itaewon-coffee'),
('경리단길 편집숍', '편집숍 거리', '이태원', '작은 소품샵과 편집숍을 구경하며 걷는 골목', 0, 9000, FALSE, TRUE, TRUE, NULL, FALSE, 'shopping', 37.5385, 126.9932, 'seed-gyeongnidan-shops'),
('우사단로 벽화거리', '벽화거리', '이태원', '언덕길을 오르며 만나는 이국적인 벽화들', 0, 5000, FALSE, FALSE, FALSE, NULL, FALSE, 'activity', 37.5375, 126.9959, 'seed-itaewon-mural'),
('이태원 소품 갤러리', '소품 갤러리', '이태원', '이색적인 소품과 작은 전시를 함께 구경해요', 5000, 12000, TRUE, FALSE, FALSE, NULL, FALSE, 'culture', 37.5348, 126.9930, 'seed-itaewon-gallery')
ON DUPLICATE KEY UPDATE name = VALUES(name), cuisine = VALUES(cuisine), has_parking = VALUES(has_parking), place_type = VALUES(place_type), indoor = VALUES(indoor), latitude = VALUES(latitude), longitude = VALUES(longitude);
