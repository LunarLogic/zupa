interface SoupProps {
  className?: string;
}

export const Soup = ({ className }: SoupProps) => (
  <svg
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    className={className}
  >
    <path
      d="M10 21H14M12 6V3M16 6V3M8 6V3M20.7805 10.9844C19.8768 15.0002 16.2887 18 12 18C7.71127 18 4.12318 15.0002 3.21949 10.9844C2.977 9.90677 3.89543 9 5 9H19C20.1046 9 21.023 9.90677 20.7805 10.9844Z"
      stroke="#191919"
      strokeWidth="1.5"
      strokeLinecap="round"
    />
  </svg>
);
