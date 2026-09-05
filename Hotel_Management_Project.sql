--
-- PostgreSQL database dump
--

\restrict pGlj8qPgWcNKXuuKZbwLLGRIGeHglq2MctWYBAgjm8I5VinyD2Vk6JipHb3aogw

-- Dumped from database version 15.18
-- Dumped by pg_dump version 15.18

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: calculate_bill_total(numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_bill_total(room_charge numeric, food_charge numeric, service_charge numeric, discount_amount numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN room_charge
         + food_charge
         + service_charge
         - discount_amount;
END;
$$;


ALTER FUNCTION public.calculate_bill_total(room_charge numeric, food_charge numeric, service_charge numeric, discount_amount numeric) OWNER TO postgres;

--
-- Name: calculate_nights(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_nights(checkin date, checkout date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN checkout - checkin;
END;
$$;


ALTER FUNCTION public.calculate_nights(checkin date, checkout date) OWNER TO postgres;

--
-- Name: calculate_total_bill(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_total_bill() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.total_amount :=
        NEW.room_charges +
        NEW.food_charges +
        NEW.service_charges -
        NEW.discount;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.calculate_total_bill() OWNER TO postgres;

--
-- Name: update_room_on_checkin(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_room_on_checkin() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status = 'Checked-In' THEN
        UPDATE room
        SET status = 'Occupied'
        WHERE room_id = NEW.room_id;
    END IF;

    IF NEW.status = 'Checked-Out' THEN
        UPDATE room
        SET status = 'Available'
        WHERE room_id = NEW.room_id;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_room_on_checkin() OWNER TO postgres;

--
-- Name: update_room_status(integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_room_status(IN p_room_id integer, IN p_status character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE room
    SET status = p_status
    WHERE room_id = p_room_id;
END;
$$;


ALTER PROCEDURE public.update_room_status(IN p_room_id integer, IN p_status character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: room; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.room (
    room_id integer NOT NULL,
    room_number character varying(10) NOT NULL,
    room_type character varying(30) NOT NULL,
    floor integer,
    price_per_day numeric(10,2),
    status character varying(20) DEFAULT 'Available'::character varying,
    CONSTRAINT room_floor_check CHECK ((floor > 0)),
    CONSTRAINT room_price_per_day_check CHECK ((price_per_day > (0)::numeric)),
    CONSTRAINT room_status_check CHECK (((status)::text = ANY ((ARRAY['Available'::character varying, 'Occupied'::character varying, 'Maintenance'::character varying])::text[])))
);


ALTER TABLE public.room OWNER TO postgres;

--
-- Name: available_rooms; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.available_rooms AS
 SELECT room.room_id,
    room.room_number,
    room.room_type,
    room.floor,
    room.price_per_day
   FROM public.room
  WHERE ((room.status)::text = 'Available'::text);


ALTER TABLE public.available_rooms OWNER TO postgres;

--
-- Name: bill; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bill (
    bill_id integer NOT NULL,
    guest_id integer,
    reservation_id integer,
    room_charges numeric(10,2) DEFAULT 0,
    food_charges numeric(10,2) DEFAULT 0,
    service_charges numeric(10,2) DEFAULT 0,
    discount numeric(10,2) DEFAULT 0,
    total_amount numeric(10,2) DEFAULT 0,
    bill_date date DEFAULT CURRENT_DATE
);


ALTER TABLE public.bill OWNER TO postgres;

--
-- Name: guest; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.guest (
    guest_id integer NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(15) NOT NULL,
    email character varying(100),
    address character varying(200),
    id_proof character varying(50) NOT NULL
);


ALTER TABLE public.guest OWNER TO postgres;

--
-- Name: reservation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservation (
    reservation_id integer NOT NULL,
    guest_id integer NOT NULL,
    room_id integer NOT NULL,
    booking_date date DEFAULT CURRENT_DATE,
    check_in_date date NOT NULL,
    check_out_date date NOT NULL,
    number_of_guests integer,
    status character varying(20) DEFAULT 'Confirmed'::character varying,
    CONSTRAINT reservation_check CHECK ((check_out_date > check_in_date)),
    CONSTRAINT reservation_number_of_guests_check CHECK ((number_of_guests > 0)),
    CONSTRAINT reservation_status_check CHECK (((status)::text = ANY ((ARRAY['Confirmed'::character varying, 'Checked-In'::character varying, 'Checked-Out'::character varying, 'Cancelled'::character varying])::text[])))
);


ALTER TABLE public.reservation OWNER TO postgres;

--
-- Name: bill_report; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.bill_report AS
 SELECT b.bill_id,
    g.name AS guest_name,
    r.reservation_id,
    b.room_charges,
    b.food_charges,
    b.service_charges,
    b.discount,
    b.total_amount,
    b.bill_date
   FROM ((public.bill b
     JOIN public.guest g ON ((b.guest_id = g.guest_id)))
     JOIN public.reservation r ON ((b.reservation_id = r.reservation_id)));


ALTER TABLE public.bill_report OWNER TO postgres;

--
-- Name: checkin_checkout; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.checkin_checkout (
    checkin_id integer NOT NULL,
    reservation_id integer NOT NULL
);


ALTER TABLE public.checkin_checkout OWNER TO postgres;

--
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    employee_id integer NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(15) NOT NULL,
    email character varying(100),
    department character varying(50) NOT NULL,
    designation character varying(50) NOT NULL,
    salary numeric(10,2),
    CONSTRAINT employee_salary_check CHECK ((salary > (0)::numeric))
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- Name: food_order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.food_order (
    order_id integer NOT NULL,
    guest_id integer NOT NULL,
    room_id integer NOT NULL,
    order_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    actual_checkin timestamp without time zone,
    actual_checkout timestamp without time zone,
    status character varying(20) DEFAULT 'Pending'::character varying
);


ALTER TABLE public.food_order OWNER TO postgres;

--
-- Name: guest_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.guest_id_seq
    START WITH 9
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.guest_id_seq OWNER TO postgres;

--
-- Name: guest_reservation_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.guest_reservation_details AS
 SELECT g.guest_id,
    g.name AS guest_name,
    g.phone,
    r.reservation_id,
    rm.room_number,
    rm.room_type,
    r.check_in_date,
    r.check_out_date,
    r.status
   FROM ((public.guest g
     JOIN public.reservation r ON ((g.guest_id = r.guest_id)))
     JOIN public.room rm ON ((r.room_id = rm.room_id)));


ALTER TABLE public.guest_reservation_details OWNER TO postgres;

--
-- Name: housekeeping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.housekeeping (
    housekeeping_id integer NOT NULL,
    room_id integer NOT NULL,
    employee_id integer NOT NULL,
    cleaning_date date DEFAULT CURRENT_DATE,
    status character varying(30) DEFAULT 'Pending'::character varying,
    CONSTRAINT housekeeping_status_check CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'In Progress'::character varying, 'Completed'::character varying])::text[])))
);


ALTER TABLE public.housekeeping OWNER TO postgres;

--
-- Name: menu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menu (
    food_id integer NOT NULL,
    food_name character varying(100) NOT NULL,
    category character varying(50) NOT NULL,
    price numeric(10,2),
    availability boolean DEFAULT true,
    CONSTRAINT menu_price_check CHECK ((price > (0)::numeric))
);


ALTER TABLE public.menu OWNER TO postgres;

--
-- Name: order_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_details (
    order_id integer NOT NULL,
    food_id integer NOT NULL,
    quantity integer,
    price numeric(10,2),
    CONSTRAINT order_details_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT order_details_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.order_details OWNER TO postgres;

--
-- Name: payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment (
    payment_id integer NOT NULL,
    bill_id integer NOT NULL,
    payment_date date DEFAULT CURRENT_DATE,
    amount numeric(10,2),
    payment_method character varying(30),
    payment_status character varying(20) DEFAULT 'Pending'::character varying,
    CONSTRAINT payment_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT payment_payment_method_check CHECK (((payment_method)::text = ANY ((ARRAY['Cash'::character varying, 'Card'::character varying, 'UPI'::character varying, 'Net Banking'::character varying])::text[]))),
    CONSTRAINT payment_payment_status_check CHECK (((payment_status)::text = ANY ((ARRAY['Pending'::character varying, 'Completed'::character varying, 'Failed'::character varying])::text[])))
);


ALTER TABLE public.payment OWNER TO postgres;

--
-- Data for Name: bill; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bill (bill_id, guest_id, reservation_id, room_charges, food_charges, service_charges, discount, total_amount, bill_date) FROM stdin;
9001	2	1002	10500.00	950.00	500.00	500.00	11450.00	2026-09-08
9002	4	1004	15200.00	740.00	800.00	1000.00	15740.00	2026-09-10
9003	7	1007	18000.00	1000.00	1000.00	2000.00	18000.00	2026-09-09
9004	1	1001	4000.00	400.00	300.00	0.00	4700.00	2026-09-12
\.


--
-- Data for Name: checkin_checkout; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checkin_checkout (checkin_id, reservation_id) FROM stdin;
1	1002
2	1004
3	1007
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee (employee_id, name, phone, email, department, designation, salary) FROM stdin;
1	Vijay Kumar	9000000001	vijay@hotel.com	Housekeeping	Supervisor	45000.00
2	Anjali Singh	9000000002	anjali@hotel.com	Housekeeping	Cleaner	28000.00
3	Raj Malhotra	9000000003	raj@hotel.com	Reception	Manager	60000.00
4	Pooja Desai	9000000004	pooja@hotel.com	Reception	Receptionist	32000.00
5	Karan Shah	9000000005	karan@hotel.com	Kitchen	Chef	40000.00
6	Meena Rao	9000000006	meena@hotel.com	Housekeeping	Cleaner	27000.00
\.


--
-- Data for Name: food_order; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.food_order (order_id, guest_id, room_id, order_date, actual_checkin, actual_checkout, status) FROM stdin;
501	2	102	2026-09-05 09:00:00	2026-09-05 14:00:00	\N	Delivered
502	4	202	2026-09-06 13:00:00	2026-09-06 14:00:00	\N	Delivered
503	1	101	2026-09-10 19:00:00	\N	\N	Pending
504	7	402	2026-09-07 20:00:00	\N	2026-09-09 11:00:00	Delivered
\.


--
-- Data for Name: guest; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.guest (guest_id, name, phone, email, address, id_proof) FROM stdin;
1	Rahul Sharma	9876543210	rahul@gmail.com	Mumbai	Aadhar
2	Priya Patil	9876543211	priya@gmail.com	Pune	Passport
3	Amit Verma	9876543212	amit@gmail.com	Delhi	Aadhar
4	Sneha Joshi	9876543213	sneha@gmail.com	Nashik	Driving License
5	Rohan Mehta	9876543214	rohan@gmail.com	Thane	Passport
6	Neha Shah	9876543215	neha@gmail.com	Surat	Aadhar
7	Arjun Rao	9876543216	arjun@gmail.com	Bangalore	Passport
8	Kavya Nair	9876543217	kavya@gmail.com	Kerala	Aadhar
\.


--
-- Data for Name: housekeeping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.housekeeping (housekeeping_id, room_id, employee_id, cleaning_date, status) FROM stdin;
1	101	2	2026-09-05	Completed
2	102	1	2026-09-05	In Progress
3	201	6	2026-09-05	Completed
4	202	2	2026-09-06	Completed
5	301	6	2026-09-06	Pending
6	401	2	2026-09-07	Completed
\.


--
-- Data for Name: menu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.menu (food_id, food_name, category, price, availability) FROM stdin;
1	Paneer Tikka	Starter	300.00	t
2	Veg Biryani	Main Course	350.00	t
3	Dal Tadka	Main Course	250.00	t
4	Butter Naan	Bread	80.00	t
5	Masala Dosa	Breakfast	200.00	t
6	Veg Sandwich	Breakfast	180.00	t
7	Fresh Lime Soda	Beverage	120.00	t
8	Gulab Jamun	Dessert	150.00	t
9	Ice Cream	Dessert	180.00	f
10	Coffee	Beverage	100.00	t
\.


--
-- Data for Name: order_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_details (order_id, food_id, quantity, price) FROM stdin;
501	1	2	300.00
501	2	1	350.00
501	4	3	80.00
502	3	2	250.00
502	7	2	120.00
503	5	1	200.00
503	10	2	100.00
504	2	2	350.00
504	8	2	150.00
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment (payment_id, bill_id, payment_date, amount, payment_method, payment_status) FROM stdin;
7001	9001	2026-09-08	11450.00	UPI	Completed
7002	9002	2026-09-10	10000.00	Card	Completed
7003	9002	2026-09-10	5740.00	Cash	Completed
7004	9003	2026-09-09	18000.00	UPI	Completed
7005	9004	2026-09-12	4700.00	Card	Completed
\.


--
-- Data for Name: reservation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservation (reservation_id, guest_id, room_id, booking_date, check_in_date, check_out_date, number_of_guests, status) FROM stdin;
1001	1	101	2026-09-01	2026-09-10	2026-09-12	1	Confirmed
1002	2	102	2026-09-01	2026-09-05	2026-09-08	2	Checked-In
1003	3	201	2026-09-02	2026-09-15	2026-09-18	2	Confirmed
1004	4	202	2026-09-03	2026-09-06	2026-09-10	3	Checked-In
1005	5	301	2026-09-03	2026-09-20	2026-09-23	2	Confirmed
1006	6	401	2026-09-04	2026-09-25	2026-09-28	4	Confirmed
1007	7	402	2026-09-04	2026-09-07	2026-09-09	2	Checked-Out
1008	8	102	2026-09-05	2026-09-30	2026-10-02	1	Confirmed
\.


--
-- Data for Name: room; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.room (room_id, room_number, room_type, floor, price_per_day, status) FROM stdin;
102	102	Single	1	2200.00	Occupied
201	201	Double	2	3500.00	Available
202	202	Double	2	3800.00	Occupied
401	401	Suite	4	8000.00	Available
402	402	Suite	4	9000.00	Occupied
301	301	Deluxe	3	5500.00	Available
302	302	Deluxe	3	6000.00	Maintenance
101	101	Single	1	2200.00	Available
\.


--
-- Name: guest_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.guest_id_seq', 9, true);


--
-- Name: bill bill_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_pkey PRIMARY KEY (bill_id);


--
-- Name: checkin_checkout checkin_checkout_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin_checkout
    ADD CONSTRAINT checkin_checkout_pkey PRIMARY KEY (checkin_id);


--
-- Name: checkin_checkout checkin_checkout_reservation_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin_checkout
    ADD CONSTRAINT checkin_checkout_reservation_id_key UNIQUE (reservation_id);


--
-- Name: employee employee_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_email_key UNIQUE (email);


--
-- Name: employee employee_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_phone_key UNIQUE (phone);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- Name: food_order food_order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_order
    ADD CONSTRAINT food_order_pkey PRIMARY KEY (order_id);


--
-- Name: guest guest_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guest
    ADD CONSTRAINT guest_email_key UNIQUE (email);


--
-- Name: guest guest_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guest
    ADD CONSTRAINT guest_phone_key UNIQUE (phone);


--
-- Name: guest guest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guest
    ADD CONSTRAINT guest_pkey PRIMARY KEY (guest_id);


--
-- Name: housekeeping housekeeping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.housekeeping
    ADD CONSTRAINT housekeeping_pkey PRIMARY KEY (housekeeping_id);


--
-- Name: menu menu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu
    ADD CONSTRAINT menu_pkey PRIMARY KEY (food_id);


--
-- Name: order_details order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_pkey PRIMARY KEY (order_id, food_id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (payment_id);


--
-- Name: reservation reservation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_pkey PRIMARY KEY (reservation_id);


--
-- Name: room room_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT room_pkey PRIMARY KEY (room_id);


--
-- Name: room room_room_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT room_room_number_key UNIQUE (room_number);


--
-- Name: idx_employee_department; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_employee_department ON public.employee USING btree (department);


--
-- Name: idx_guest_phone; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_guest_phone ON public.guest USING btree (phone);


--
-- Name: idx_reservation_guest; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservation_guest ON public.reservation USING btree (guest_id);


--
-- Name: idx_reservation_room; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservation_room ON public.reservation USING btree (room_id);


--
-- Name: idx_room_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_room_status ON public.room USING btree (status);


--
-- Name: bill trg_calculate_bill; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_calculate_bill BEFORE INSERT OR UPDATE ON public.bill FOR EACH ROW EXECUTE FUNCTION public.calculate_total_bill();


--
-- Name: reservation trg_room_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_room_status AFTER INSERT OR UPDATE OF status ON public.reservation FOR EACH ROW EXECUTE FUNCTION public.update_room_on_checkin();


--
-- Name: bill bill_guest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES public.guest(guest_id);


--
-- Name: bill bill_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.reservation(reservation_id);


--
-- Name: checkin_checkout checkin_checkout_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin_checkout
    ADD CONSTRAINT checkin_checkout_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.reservation(reservation_id) ON DELETE CASCADE;


--
-- Name: food_order food_order_guest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_order
    ADD CONSTRAINT food_order_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES public.guest(guest_id);


--
-- Name: food_order food_order_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_order
    ADD CONSTRAINT food_order_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.room(room_id);


--
-- Name: housekeeping housekeeping_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.housekeeping
    ADD CONSTRAINT housekeeping_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);


--
-- Name: housekeeping housekeeping_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.housekeeping
    ADD CONSTRAINT housekeeping_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.room(room_id);


--
-- Name: order_details order_details_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.menu(food_id) ON DELETE RESTRICT;


--
-- Name: order_details order_details_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.food_order(order_id) ON DELETE CASCADE;


--
-- Name: payment payment_bill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_bill_id_fkey FOREIGN KEY (bill_id) REFERENCES public.bill(bill_id) ON DELETE CASCADE;


--
-- Name: reservation reservation_guest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES public.guest(guest_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reservation reservation_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.room(room_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: TABLE guest; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.guest TO hotel_manager;


--
-- Name: TABLE reservation; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.reservation TO hotel_manager;


--
-- PostgreSQL database dump complete
--

\unrestrict pGlj8qPgWcNKXuuKZbwLLGRIGeHglq2MctWYBAgjm8I5VinyD2Vk6JipHb3aogw

