export const SITE_URL = (process.env.NEXT_PUBLIC_SITE_URL || "https://ankitkanojiya.com").replace(/\/$/, "");
export const SITE_NAME = "Ankit Kanojiya";
export const BOOKING_URL = "https://calendly.com/ankitkanojiya07/book-appointment-with-ankit";
export const abs = (path: string) => `${SITE_URL}${path}`;
