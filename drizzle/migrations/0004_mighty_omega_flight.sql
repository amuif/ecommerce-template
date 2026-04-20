CREATE TYPE "public"."product_category" AS ENUM('t-shirts', 'pants', 'sweatshirts');--> statement-breakpoint
CREATE TYPE "public"."sizes" AS ENUM('XS', 'S', 'M', 'L', 'XL', 'XXL');--> statement-breakpoint
CREATE TABLE "cart_items" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"variant_id" bigint NOT NULL,
	"quantity" integer DEFAULT 1 NOT NULL,
	"size" "sizes" NOT NULL,
	"stripe_id" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "cart_user_variant_size_unique" UNIQUE("user_id","variant_id","size"),
	CONSTRAINT "quantity_positive" CHECK (quantity > 0)
);
--> statement-breakpoint
ALTER TABLE "cart_items" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "customer_info" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"order_id" bigint NOT NULL,
	"name" text NOT NULL,
	"email" text NOT NULL,
	"phone" text,
	"address" jsonb NOT NULL,
	"stripe_order_id" text NOT NULL,
	"total_price" bigint NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "customer_info_order_id_unique" UNIQUE("order_id"),
	CONSTRAINT "customer_info_stripe_order_id_unique" UNIQUE("stripe_order_id")
);
--> statement-breakpoint
ALTER TABLE "customer_info" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "order_items" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"delivery_date" timestamp with time zone NOT NULL,
	"order_number" bigint NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "order_items_order_number_unique" UNIQUE("order_number")
);
--> statement-breakpoint
ALTER TABLE "order_items" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "order_products" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"order_id" bigint NOT NULL,
	"variant_id" bigint NOT NULL,
	"quantity" integer NOT NULL,
	"size" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "order_quantity_positive" CHECK (quantity > 0)
);
--> statement-breakpoint
ALTER TABLE "order_products" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "products_items" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"name" varchar(255) NOT NULL,
	"description" text NOT NULL,
	"price" numeric(10, 2) NOT NULL,
	"category" "product_category" NOT NULL,
	"img" varchar(500) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "price_positive" CHECK (price > 0)
);
--> statement-breakpoint
ALTER TABLE "products_items" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "products_variants" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"product_id" bigint NOT NULL,
	"stripe_id" varchar(255) NOT NULL,
	"color" varchar(100) NOT NULL,
	"sizes" "sizes"[] NOT NULL,
	"images" text[] NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "products_variants_stripe_id_unique" UNIQUE("stripe_id"),
	CONSTRAINT "product_color_unique" UNIQUE("product_id","color")
);
--> statement-breakpoint
ALTER TABLE "products_variants" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "user" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"email" text NOT NULL,
	"email_verified" boolean DEFAULT false NOT NULL,
	"image" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "user_email_unique" UNIQUE("email")
);
--> statement-breakpoint
ALTER TABLE "user" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "wishlist" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"product_id" bigint NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "wishlist_user_product_unique" UNIQUE("user_id","product_id")
);
--> statement-breakpoint
ALTER TABLE "wishlist" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
ALTER TABLE "cart_items" ADD CONSTRAINT "cart_items_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "cart_items" ADD CONSTRAINT "cart_items_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "public"."products_variants"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "customer_info" ADD CONSTRAINT "customer_info_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."order_items"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "order_products" ADD CONSTRAINT "order_products_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."order_items"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "order_products" ADD CONSTRAINT "order_products_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "public"."products_variants"("id") ON DELETE restrict ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "products_variants" ADD CONSTRAINT "products_variants_product_id_products_items_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."products_items"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "wishlist" ADD CONSTRAINT "wishlist_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "wishlist" ADD CONSTRAINT "wishlist_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products_items"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
CREATE INDEX "idx_cart_user_id" ON "cart_items" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_cart_variant_id" ON "cart_items" USING btree ("variant_id");--> statement-breakpoint
CREATE INDEX "idx_cart_updated_at" ON "cart_items" USING btree ("updated_at");--> statement-breakpoint
CREATE INDEX "idx_cart_user_variant_size" ON "cart_items" USING btree ("user_id","variant_id","size");--> statement-breakpoint
CREATE INDEX "idx_customer_info_order_id" ON "customer_info" USING btree ("order_id");--> statement-breakpoint
CREATE INDEX "idx_customer_info_stripe_order_id" ON "customer_info" USING btree ("stripe_order_id");--> statement-breakpoint
CREATE INDEX "idx_customer_info_email" ON "customer_info" USING btree ("email");--> statement-breakpoint
CREATE INDEX "idx_order_items_user_id" ON "order_items" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_order_items_order_number" ON "order_items" USING btree ("order_number");--> statement-breakpoint
CREATE INDEX "idx_order_items_created_at" ON "order_items" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "idx_order_items_delivery_date" ON "order_items" USING btree ("delivery_date");--> statement-breakpoint
CREATE INDEX "idx_order_items_user_created" ON "order_items" USING btree ("user_id","created_at");--> statement-breakpoint
CREATE INDEX "idx_order_products_order_id" ON "order_products" USING btree ("order_id");--> statement-breakpoint
CREATE INDEX "idx_order_products_variant_id" ON "order_products" USING btree ("variant_id");--> statement-breakpoint
CREATE INDEX "idx_products_category" ON "products_items" USING btree ("category");--> statement-breakpoint
CREATE INDEX "idx_products_name" ON "products_items" USING btree ("name");--> statement-breakpoint
CREATE INDEX "idx_products_created_at" ON "products_items" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "idx_products_updated_at" ON "products_items" USING btree ("updated_at");--> statement-breakpoint
CREATE INDEX "idx_variants_product_id" ON "products_variants" USING btree ("product_id");--> statement-breakpoint
CREATE INDEX "idx_variants_stripe_id" ON "products_variants" USING btree ("stripe_id");--> statement-breakpoint
CREATE INDEX "idx_variants_color" ON "products_variants" USING btree ("color");--> statement-breakpoint
CREATE INDEX "idx_variants_created_at" ON "products_variants" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "idx_variants_updated_at" ON "products_variants" USING btree ("updated_at");--> statement-breakpoint
CREATE INDEX "idx_user_email" ON "user" USING btree ("email");--> statement-breakpoint
CREATE INDEX "idx_user_created_at" ON "user" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "idx_wishlist_user_id" ON "wishlist" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_wishlist_product_id" ON "wishlist" USING btree ("product_id");--> statement-breakpoint
CREATE INDEX "idx_wishlist_updated_at" ON "wishlist" USING btree ("updated_at");--> statement-breakpoint
CREATE INDEX "idx_wishlist_user_product" ON "wishlist" USING btree ("user_id","product_id");--> statement-breakpoint
CREATE POLICY "Users can view own cart items" ON "cart_items" AS PERMISSIVE FOR SELECT TO public USING (app.current_user_id() = user_id);--> statement-breakpoint
CREATE POLICY "Users can insert own cart items" ON "cart_items" AS PERMISSIVE FOR INSERT TO public WITH CHECK (app.current_user_id() = user_id);--> statement-breakpoint
CREATE POLICY "Users can update own cart items" ON "cart_items" AS PERMISSIVE FOR UPDATE TO public USING (app.current_user_id() = user_id) WITH CHECK (app.current_user_id() = user_id);--> statement-breakpoint
CREATE POLICY "Users can delete own cart items" ON "cart_items" AS PERMISSIVE FOR DELETE TO public USING (app.current_user_id() = user_id);--> statement-breakpoint
CREATE POLICY "Backend can manage customer info" ON "customer_info" AS PERMISSIVE FOR ALL TO public USING (current_setting('request.jwt.claim.role', true) is null) WITH CHECK (current_setting('request.jwt.claim.role', true) is null);--> statement-breakpoint
CREATE POLICY "Users can view own customer info" ON "customer_info" AS PERMISSIVE FOR SELECT TO public USING (exists (select 1 from order_items where order_items.id = order_id and order_items.user_id = app.current_user_id()));--> statement-breakpoint
CREATE POLICY "Backend can manage orders" ON "order_items" AS PERMISSIVE FOR ALL TO public USING (current_setting('request.jwt.claim.role', true) is null) WITH CHECK (current_setting('request.jwt.claim.role', true) is null);--> statement-breakpoint
CREATE POLICY "Users can view own orders" ON "order_items" AS PERMISSIVE FOR SELECT TO public USING (app.current_user_id() = user_id);--> statement-breakpoint
CREATE POLICY "Backend can manage order products" ON "order_products" AS PERMISSIVE FOR ALL TO public USING (current_setting('request.jwt.claim.role', true) is null) WITH CHECK (current_setting('request.jwt.claim.role', true) is null);--> statement-breakpoint
CREATE POLICY "Users can view own order products" ON "order_products" AS PERMISSIVE FOR SELECT TO public USING (exists (select 1 from order_items where order_items.id = order_id and order_items.user_id = app.current_user_id()));--> statement-breakpoint
CREATE POLICY "Backend can manage products" ON "products_items" AS PERMISSIVE FOR ALL TO public USING (current_setting('request.jwt.claim.role', true) is null) WITH CHECK (current_setting('request.jwt.claim.role', true) is null);--> statement-breakpoint
CREATE POLICY "Anyone can view products" ON "products_items" AS PERMISSIVE FOR SELECT TO "anon" USING (true);--> statement-breakpoint
CREATE POLICY "Backend can manage variants" ON "products_variants" AS PERMISSIVE FOR ALL TO public USING (current_setting('request.jwt.claim.role', true) is null) WITH CHECK (current_setting('request.jwt.claim.role', true) is null);--> statement-breakpoint
CREATE POLICY "Anyone can view variants" ON "products_variants" AS PERMISSIVE FOR SELECT TO "anon" USING (true);--> statement-breakpoint
CREATE POLICY "Backend can manage auth users" ON "user" AS PERMISSIVE FOR ALL TO public USING (current_setting('request.jwt.claim.role', true) is null) WITH CHECK (current_setting('request.jwt.claim.role', true) is null);--> statement-breakpoint
CREATE POLICY "Users can view own profile" ON "user" AS PERMISSIVE FOR SELECT TO public USING (app.current_user_id() = id);--> statement-breakpoint
CREATE POLICY "Users can update own profile" ON "user" AS PERMISSIVE FOR UPDATE TO public USING (app.current_user_id() = id) WITH CHECK (app.current_user_id() = id);--> statement-breakpoint
CREATE POLICY "Users can view own wishlist items" ON "wishlist" AS PERMISSIVE FOR SELECT TO public USING (app.current_user_id() = user_id);--> statement-breakpoint
CREATE POLICY "Users can insert own wishlist items" ON "wishlist" AS PERMISSIVE FOR INSERT TO public WITH CHECK (app.current_user_id() = user_id);--> statement-breakpoint
CREATE POLICY "Users can delete own wishlist items" ON "wishlist" AS PERMISSIVE FOR DELETE TO public USING (app.current_user_id() = user_id);