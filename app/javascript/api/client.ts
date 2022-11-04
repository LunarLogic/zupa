import axios, { AxiosError, AxiosResponse } from "axios";
import { camelizeKeys } from "humps";

import { paths } from "../utils/paths";

const UNAUTHORIZED_STATUS_CODE = 401;
const PAGE_NOT_FOUND_STATUS_CODE = 404;

const axiosClient = axios.create({
  headers: {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
  },
  baseURL: process.env.REACT_API_BASE_URL,
});

const handleSuccessResponse = (response: AxiosResponse) => {
  const contentType = response.headers["content-type"];
  if (contentType && contentType.includes("application/json")) {
    response.data = camelizeKeys(response.data);
    return response;
  } else {
    console.error("Response data is not in JSON format");
    throw new Error("Response data is not in JSON format");
  }
};

const handleErrorResponse = (error: AxiosError) => {
  if (error.response?.status === PAGE_NOT_FOUND_STATUS_CODE) {
    window.location.href = paths.pageNotFound;
  }
  if (error.response?.status === UNAUTHORIZED_STATUS_CODE) {
    handleSessionExpired();
  }
  console.error(error.message);
  throw new Error(error.message);
};

const handleSessionExpired = () => {
  localStorage.removeItem("authToken");
  window.location.href = paths.main;
};

axiosClient.interceptors.response.use(handleSuccessResponse, handleErrorResponse);

axiosClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("authToken");
    if (token) {
      config.headers["Authorization"] = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    console.error(error);
    return Promise.reject(error);
  }
);

export default axiosClient;
