-- Stored procedure to set a user's role and, when role is trainer, upsert specialty in TRAINERS
-- Behavior mirrors the existing JSP: promote to trainer ensures a TRAINERS row exists and sets specialty;
-- changing to non-trainer does not remove the TRAINERS row (removal is handled elsewhere).

CREATE OR REPLACE PROCEDURE set_user_role(
  p_user_id   IN NUMBER,
  p_role      IN VARCHAR2,
  p_specialty IN VARCHAR2 DEFAULT NULL
) AS
BEGIN
  -- Update role on USERS
  UPDATE users
     SET role = LOWER(p_role)
   WHERE user_id = p_user_id;

  -- If becoming a trainer, upsert specialty into TRAINERS
  IF LOWER(p_role) = 'trainer' THEN
    MERGE INTO trainers t
    USING (
      SELECT p_user_id AS user_id, p_specialty AS specialty FROM dual
    ) s
    ON (t.user_id = s.user_id)
    WHEN MATCHED THEN
      UPDATE SET t.specialty = s.specialty
    WHEN NOT MATCHED THEN
      INSERT (user_id, specialty)
      VALUES (s.user_id, s.specialty);
  END IF;
END;
/
SHOW ERRORS PROCEDURE set_user_role;
