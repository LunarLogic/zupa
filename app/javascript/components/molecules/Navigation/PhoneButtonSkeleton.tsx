import React from "react";
import Skeleton from "react-loading-skeleton";

const PhoneButtonSkeleton: React.FC = () => {
  return (
    <>
      <Skeleton width={42} height={32} enableAnimation duration={1} />
    </>
  );
};

export default PhoneButtonSkeleton;
