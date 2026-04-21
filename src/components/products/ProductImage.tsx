/** COMPONENTS */
import Image from "next/image";
/** FUNCTIONALITY */
import { cn } from "@/lib/utils";
import { Suspense, ViewTransition } from 'react'
/** TYPES */
import type { Product, ProductVariant } from "@/lib/db/drizzle/schema";
import { ProductsSkeleton } from "@/components/products";
interface ProductImageProps {
  image: ProductVariant["images"][number];
  name: Product["name"];
  width: number;
  height: number;
  sizes: string;
  priority?: boolean;
  quality?: number;
  unoptimized?: boolean;
  blurDataURL?: string | null;
  className?: string;
  id?: number
}

export const ProductImage = ({
  image,
  name,
  width,
  height,
  priority,
  sizes,
  quality,
  unoptimized,
  blurDataURL,
  className,
  id
}: ProductImageProps) => {
  return (
    <Suspense fallback={
      <ViewTransition exit="slide-down">
        <ProductsSkeleton items={1} />
      </ViewTransition>
    }>
      <div
        className="relative w-full overflow-hidden"
        style={{ aspectRatio: `${width} / ${height}` }}
      >
        <ViewTransition name={id?.toString()} share='morph'>
          <Image
            fill
            src={image}
            alt={name}
            priority={priority}
            placeholder={blurDataURL ? "blur" : "empty"}
            blurDataURL={blurDataURL ?? undefined}
            quality={quality}
            unoptimized={unoptimized}
            sizes={sizes}
            className={cn("object-cover brightness-90", className)}
          />
        </ViewTransition>
      </div>
    </Suspense>
  );
};
