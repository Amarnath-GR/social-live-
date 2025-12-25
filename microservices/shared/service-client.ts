import axios, { AxiosInstance } from 'axios';
import { ServiceResponse } from './types';

export class ServiceClient {
  private client: AxiosInstance;

  constructor(baseURL: string, serviceName: string) {
    this.client = axios.create({
      baseURL,
      timeout: 5000,
      headers: {
        'Content-Type': 'application/json',
        'X-Service-Name': serviceName,
      },
    });
  }

  async get<T>(path: string, headers?: Record<string, string>): Promise<ServiceResponse<T>> {
    try {
      const response = await this.client.get(path, { headers });
      return response.data;
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async post<T>(path: string, data: any, headers?: Record<string, string>): Promise<ServiceResponse<T>> {
    try {
      const response = await this.client.post(path, data, { headers });
      return response.data;
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async put<T>(path: string, data: any, headers?: Record<string, string>): Promise<ServiceResponse<T>> {
    try {
      const response = await this.client.put(path, data, { headers });
      return response.data;
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async delete<T>(path: string, headers?: Record<string, string>): Promise<ServiceResponse<T>> {
    try {
      const response = await this.client.delete(path, { headers });
      return response.data;
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
}