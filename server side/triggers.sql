DROP TRIGGER IF EXISTS user_registered ON chatapp.users;
DROP TRIGGER IF EXISTS help_messages_sent ON chatapp.messages;
DROP TRIGGER IF EXISTS message_send_check ON chatapp.messages;
DROP TRIGGER IF EXISTS message_send_check_bff ON chatapp.messages;
DROP TRIGGER IF EXISTS log ON chatapp.users;
DROP TRIGGER IF EXISTS request ON chatapp.requests;
DROP TRIGGER IF EXISTS blocking_log ON chatapp.relationship;

CREATE OR REPLACE FUNCTION chatapp.send_hello_message() RETURNS TRIGGER AS
$$

DECLARE
admin_id INT:= 0;
message VARCHAR(100):='';

BEGIN

IF (SELECT COUNT(*) FROM chatapp.users WHERE username = NEW.username OR email = NEW.email) > 1 THEN
  RAISE EXCEPTION 'Username or email already exists';
END IF;

SELECT INTO admin_id user_id FROM chatapp.users WHERE username = 'admin';

message := 'Hello, ' || NEW.username || '. Welcome to ChatApp! Type ''options'' for a list of options.';

INSERT INTO chatapp.messages(message_id, user_id_from, user_id_to, message_text, time_sent)
VALUES(DEFAULT, admin_id, NEW.user_id, message, DEFAULT);

RAISE NOTICE 'Hello message sent!';

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_registered
AFTER INSERT OR UPDATE ON chatapp.users
FOR EACH ROW
EXECUTE PROCEDURE chatapp.send_hello_message();

--
--CHECK IF HELP MEssage is sent to admin
--
CREATE OR REPLACE FUNCTION chatapp.help_messages() RETURNS TRIGGER AS
$$

DECLARE
message VARCHAR(200):='';

BEGIN

IF NEW.user_id_to = (SELECT user_id FROM chatapp.users WHERE username = 'admin') THEN
  CASE NEW.message_text
    WHEN 'options' THEN message := 'Hi, ' || (SELECT first_name FROM chatapp.users WHERE user_id = NEW.user_id_from) || '\nHere is a list of options.'
                                '\n''options''- option list\n'
                                '''info''- application info\n'
                                '''help''- application help\n';
    WHEN 'info' THEN message := 'ChatApp, all rights reserved (C) 2015, Database Theory, Darijan Vertovsek';
    WHEN 'help' THEN message := 'OVO JOS TRIBA ZITISLO kad se ISPROGRAMIRA APP';
    ELSE message := 'Unknown option. Type ''options'' for option list.';
  END CASE;
END IF;

IF message != '' THEN
  INSERT INTO chatapp.messages(message_id, user_id_from, user_id_to, message_text, is_public, time_sent)
  VALUES(DEFAULT, (SELECT user_id FROM chatapp.users WHERE username = 'admin'), NEW.user_id_from, message, FALSE, DEFAULT);
END IF;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER help_messages_sent
AFTER INSERT ON chatapp.messages
FOR EACH ROW
EXECUTE PROCEDURE chatapp.help_messages();

CREATE OR REPLACE FUNCTION chatapp.message_check() RETURNS TRIGGER AS
$$

DECLARE
recordRel chatapp.relationship%ROWTYPE;
recordUsers chatapp.users%ROWTYPE;

BEGIN

IF NEW.user_id_from != (SELECT user_id FROM chatapp.users WHERE username = 'admin') AND NEW.user_id_to != (SELECT user_id FROM chatapp.users WHERE username = 'admin') THEN

  SELECT * INTO recordRel FROM chatapp.relationship WHERE (user_1 = NEW.user_id_from OR user_1 = NEW.user_id_to) AND (user_2 = NEW.user_id_from OR user_2 = NEW.user_id_to);
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Message cannot be sent!' USING DETAIL = 'Users are not friends!';
  END IF;

END IF;

recordRel := NULL;

SELECT * INTO recordRel FROM chatapp.relationship WHERE (user_1 = NEW.user_id_from OR user_1 = NEW.user_id_to) AND (user_2 = NEW.user_id_from OR user_2 = NEW.user_id_to) AND user1_blocked_user2 = TRUE;
IF FOUND THEN
  RAISE EXCEPTION 'Message cannot be sent!' USING DETAIL = 'Users are blocked!';
END IF;

IF NEW.is_public = true AND NEW.user_id_from != NEW.user_id_to THEN

  RAISE NOTICE 'public message, different users!';

  IF NEW.user_id_to = 1 THEN
    RAISE EXCEPTION 'You cant write on admin''s wall!';
  END IF;

  recordRel := NULL;
  SELECT * INTO recordRel FROM chatapp.relationship WHERE (user_1 = NEW.user_id_from OR user_1 = NEW.user_id_to) AND (user_2 = NEW.user_id_from OR user_2 = NEW.user_id_to) AND best_friends = TRUE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Public message cannot be sent!' USING DETAIL = 'Users are not best friends!';
  END IF;

END IF;

SELECT * INTO recordUsers FROM chatapp.users WHERE user_id = NEW.user_id_to AND user_status_id = (SELECT status_id FROM chatapp.user_status WHERE description = 'active');
IF NOT FOUND THEN
  RAISE EXCEPTION 'Message cannot be sent!' USING DETAIL = 'User is blocked or non-active';
END IF;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER message_send_check
BEFORE INSERT ON chatapp.messages
FOR EACH ROW
EXECUTE PROCEDURE chatapp.message_check();

--
--checks if users became best friends
--
CREATE OR REPLACE FUNCTION chatapp.message_check_bff() RETURNS TRIGGER AS
$$

DECLARE
message_number_usr1_to2 INT := 0;
message_number_usr2_to1 INT := 0;

BEGIN

IF NEW.user_id_from != 1 AND NEW.user_id_to != 1 THEN
  SELECT INTO message_number_usr1_to2 COUNT(*) FROM chatapp.messages WHERE user_id_from = NEW.user_id_from AND user_id_to = NEW.user_id_to;
  SELECT INTO message_number_usr2_to1 COUNT(*) FROM chatapp.messages WHERE user_id_from = NEW.user_id_to AND user_id_to = NEW.user_id_from;

  IF message_number_usr1_to2 > 5 AND message_number_usr2_to1 > 5 THEN
    UPDATE chatapp.relationship SET best_friends = true WHERE user_1 = NEW.user_id_from OR user_1 = NEW.user_id_to AND user_2 = NEW.user_id_from OR user_2 = NEW.user_id_to;
  END IF;
END IF;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER message_send_check_bff
AFTER INSERT ON chatapp.messages
FOR EACH ROW
EXECUTE PROCEDURE chatapp.message_check_bff();



--
-- log controller
--
CREATE OR REPLACE FUNCTION chatapp.log() RETURNS TRIGGER AS
$$

DECLARE
usr_status_id INT := 0;

BEGIN

--if user logs out or logs in
IF (NEW.on_line != OLD.on_line) THEN

  SELECT INTO usr_status_id user_status_id FROM chatapp.users WHERE NEW.user_id;
  CASE usr_status_id
    WHEN 2 THEN RAISE EXCEPTION 'User cannot log-in' USING DETAIL = 'User is blocked';
    WHEN 3 THEN RAISE EXCEPTION 'User cannot log-in' USING DETAIL = 'User is non-active';
  END CASE;

  CASE NEW.on_line
    WHEN TRUE THEN INSERT INTO chatapp.log(user_id, description, log_time) VALUES (NEW.user_id, 'Login', DEFAULT);
    WHEN FALSE THEN INSERT INTO chatapp.log(user_id, description, log_time) VALUES (NEW.user_id, 'Logout', DEFAULT);
  END CASE;
END IF;

--if user changed status_id
IF (NEW.user_status_id != OLD.user_status_id) THEN
  CASE NEW.user_status_id
    WHEN 1 THEN INSERT INTO chatapp.log(user_id, description, log_time) VALUES (NEW.user_id, 'User active', DEFAULT);
    WHEN 2 THEN INSERT INTO chatapp.log(user_id, description, log_time) VALUES (NEW.user_id, 'User blocked', DEFAULT);
    WHEN 3 THEN INSERT INTO chatapp.log(user_id, description, log_time) VALUES (NEW.user_id, 'User non-active', DEFAULT);
  END CASE;
END IF;

--if user changes username
IF (NEW.username != OLD.username) THEN
  INSERT INTO chatapp.log(user_id, description, log_time) VALUES (NEW.user_id, 'Changed username from ' || OLD.username || ' to ' || NEW.username, DEFAULT);
END IF;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log
AFTER UPDATE ON chatapp.users
FOR EACH ROW
EXECUTE PROCEDURE chatapp.log();

CREATE OR REPLACE FUNCTION chatapp.block_log() RETURNS TRIGGER AS
$$

DECLARE
record chatapp.relationship%ROWTYPE;

BEGIN

CASE tg_op
WHEN 'INSERT' THEN
  SELECT * INTO record FROM chatapp.relationship WHERE user_1 = NEW.user_1 AND user_2 = NEW.user_2 AND user1_blocked_user2 = true;
  IF FOUND THEN
    INSERT INTO chatapp.log(user_id, description, log_time) VALUES (NEW.user_1, ' blocked user: ' || (SELECT username FROM chatapp.users WHERE user_id = NEW.user_2), DEFAULT);
  END IF;
WHEN 'UPDATE' THEN
  SELECT * INTO record FROM chatapp.relationship WHERE user_1 = NEW.user_1 AND user_2 = NEW.user_2 AND user1_blocked_user2 = false;
  IF FOUND AND OLD.user1_blocked_user2 != NEW.user1_blocked_user2 THEN
    INSERT INTO chatapp.log(user_id, description, log_time) VALUES (NEW.user_1, ' deblocked user: ' || (SELECT username FROM chatapp.users WHERE user_id = NEW.user_2), DEFAULT);
  END IF;
END CASE;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER blocking_log
AFTER UPDATE OR INSERT ON chatapp.relationship
FOR EACH ROW
EXECUTE PROCEDURE chatapp.block_log();

--user cant add
CREATE OR REPLACE FUNCTION chatapp.request_check() RETURNS TRIGGER AS
$$

DECLARE
record chatapp.requests%ROWTYPE;
hour VARCHAR(5) := '';
minutes VARCHAR(5) := '';

BEGIN

IF tg_op = 'UPDATE' THEN
  IF NEW.accepted = true THEN
    INSERT INTO chatapp.relationship(user_1, user_2, best_friends, user1_blocked_user2) VALUES (NEW.user_id_from,NEW.user_id_to,false,false);
    INSERT INTO chatapp.log(user_id, description, log_time) VALUES (NEW.user_id_to, ' user accepted ' || (SELECT username FROM chatapp.users WHERE user_id = NEW.user_id_from), DEFAULT);
  ELSE
    INSERT INTO chatapp.log(user_id, description, log_time) VALUES (NEW.user_id_to, ' user dismissed ' || (SELECT username FROM chatapp.users WHERE user_id = NEW.user_id_from), DEFAULT);
  END IF;
--if tg_op = "INSERT"
ELSE
  SELECT * INTO record FROM chatapp.requests
  WHERE user_id_from = NEW.user_id_from AND user_id_to = NEW.user_id_to AND accepted = false AND (chatapp.gettime() - time_sent) < interval '12 hours';

  IF NEW.user_id_from = NEW.user_id_to THEN
    RAISE EXCEPTION 'You cannot send a request to yourself!';
  END IF;

  IF FOUND THEN
    SELECT INTO hour EXTRACT(hour FROM (chatapp.gettime() - time_sent))
    FROM chatapp.requests
    WHERE user_id_from = NEW.user_id_from AND user_id_to = NEW.user_id_to AND (chatapp.gettime() - time_sent) < interval '12 hours';

    SELECT INTO minutes EXTRACT(minutes FROM (chatapp.gettime() - time_sent))
    FROM chatapp.requests
    WHERE user_id_from = NEW.user_id_from AND user_id_to = NEW.user_id_to AND (chatapp.gettime() - time_sent) < interval '12 hours';

    RAISE EXCEPTION 'Cannot send a request!' USING DETAIL = 'You have already sent a request ' || hour || ' hour(s) and ' || minutes || ' minute(s) ago';
  END IF;

  SELECT * INTO record FROM chatapp.requests
  WHERE user_id_from = NEW.user_id_from AND user_id_to = NEW.user_id_to AND accepted IS NULL;
  IF FOUND THEN
    RAISE EXCEPTION 'You already sent a request to %', (SELECT username FROM chatapp.users WHERE user_id = NEW.user_id_to);
  END IF;

RAISE NOTICE 'Request successfuly sent!';

END IF;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER request
BEFORE INSERT OR UPDATE ON chatapp.requests
FOR EACH ROW
EXECUTE PROCEDURE chatapp.request_check();
