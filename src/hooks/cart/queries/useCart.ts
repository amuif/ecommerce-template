import { useQuery } from "@tanstack/react-query";
import { CART_QUERY_KEYS } from "../keys";
import { selectCartItemSchema, type CartItem } from "@/lib/db/drizzle/schema";
import { useSession } from "@/lib/auth/client";
import type { CartListResponse } from "../types";

export const useCart = () => {
  const { data: session } = useSession();
  const userId = session?.user?.id;

  const query = useQuery({
    enabled: Boolean(userId),
    queryKey: CART_QUERY_KEYS.cartList(userId ?? "anonymous"),
    queryFn: async () => {
      const response = await fetch("/api/user/cart", {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (!response.ok) {
        throw new Error("Failed to fetch cart");
      }

      const data = await response.json();
      return {
        items: selectCartItemSchema.array().parse(data.items),
      } satisfies CartListResponse;
    },
  });

  const items = query.data?.items ?? [];

  const getCartItemById = (id: CartItem["id"]): CartItem | undefined => {
    return items.find((item) => item.id === id);
  };

  return {
    ...query,
    items,
    getCartItemById,
  };
};
