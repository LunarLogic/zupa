interface ArrowRigthProps {
  className: string;
}

export const ArrowRight = ({ className }: ArrowRigthProps) => (
  <svg
    width="100%"
    height="100%"
    viewBox="0 0 20 18"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    className={className}
  >
    <path
      d="M11.5 1.5L19 9M19 9L11.5 16.5M19 9H1"
      stroke="#191919"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  </svg>
);
