interface ConfusedSmileysProps {
  className: string;
  show: boolean;
}

export const ConfusedSmileys = ({ className, show }: ConfusedSmileysProps) => {
  if (!show) return null;

  return (
    <svg viewBox="0 0 360 234" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <path
        d="M0 117C0 52.3827 52.3827 0 117 0C181.617 0 234 52.3827 234 117V234H0V117Z"
        fill="#FDD051"
      />
      <path
        d="M199 153.5C199 109.041 235.041 73 279.5 73C323.959 73 360 109.041 360 153.5V234H199V153.5Z"
        fill="#006653"
      />
      <circle cx="89" cy="73" r="5" fill="#191919" />
      <circle cx="222" cy="172" r="5" fill="#191919" />
      <circle cx="138" cy="73" r="5" fill="#191919" />
      <circle cx="252" cy="172" r="5" fill="#191919" />
      <line
        x1="101.5"
        y1="84.5"
        x2="124.5"
        y2="84.5"
        stroke="#191919"
        strokeWidth="3"
        strokeLinecap="round"
      />
      <line
        x1="233.5"
        y1="183.5"
        x2="240.5"
        y2="183.5"
        stroke="#191919"
        strokeWidth="3"
        strokeLinecap="round"
      />
    </svg>
  );
};
