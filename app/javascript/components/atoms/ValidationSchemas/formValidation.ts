import { z } from "zod";

export const ItemRequestFormSchema = z.object({
  size: z.string().min(1, { message: "Uzupełnij rozmiar" }),
});

export type ItemRequestFormSchemaType = z.infer<typeof ItemRequestFormSchema>;

export const LoginFormSchema = z.object({
  name: z.string().min(1, { message: "Uzupełnij swoje imię i nazwisko" }),
  code: z.string().min(1, { message: "Uzupełnij kod dostępu" }),
});
