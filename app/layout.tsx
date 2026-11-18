import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "ONIX AI Connect | Atendimento inteligente", description: "Central inteligente de atendimento, leads e automação por WhatsApp." };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="pt-BR"><body>{children}</body></html>;
}
