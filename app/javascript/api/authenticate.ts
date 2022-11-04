import axiosClient from "./client";
import { endpoints } from "./endpoints";

const authenticate = async (credentials: { name: string; code: string }) => {
  try {
    const response = await axiosClient.post(endpoints.authenticate, {
      user_name: credentials.name,
      auth_code: credentials.code,
    });
    const token = response?.data?.token;
    if (token) {
      localStorage.setItem("authToken", token);
      return true;
    } else {
      console.error("Invalid response data:", response);
      return false;
    }
  } catch (error) {
    console.error(error);
    return false;
  }
};

export default authenticate;
