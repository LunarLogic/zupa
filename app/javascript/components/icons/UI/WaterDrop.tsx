interface WaterDropProps {
  className?: string;
}

export const WaterDrop = ({ className }: WaterDropProps) => (
  <svg
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    className={className}
  >
    <path
      d="M19 14C19 17.866 15.866 21 12 21C8.13401 21 5 17.866 5 14C5 10.6562 10.2366 4.86769 11.6513 3.36486C11.8431 3.16109 12.1569 3.16109 12.3487 3.36486C13.7634 4.86769 19 10.6562 19 14Z"
      stroke="#191919"
      strokeWidth="1.5"
    />
  </svg>
);
