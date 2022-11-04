interface ArrowLeftProps {
  className?: string;
}

export const ArrowLeft = ({ className }: ArrowLeftProps) => (
  <svg width="20" height="18" viewBox="0 0 20 18" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path
      d="M8.5 16.5L1 9M1 9L8.5 1.5M1 9H19"
      stroke="#006653"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
    />
  </svg>
);
