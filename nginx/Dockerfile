FROM nginx:latest

# Copy custom Nginx configuration file
COPY gophish_admin.conf /etc/nginx/conf.d/gophish_admin.conf

ARG GOPHISH_HOST
ARG EVILGOPHISH_HOST

# Replace placeholder with actual ip address
RUN sed -i "s/GOPHISH_HOST/$GOPHISH_HOST/g" /etc/nginx/conf.d/gophish_admin.conf
RUN sed -i "s/EVILGOPHISH_HOST/$EVILGOPHISH_HOST/g" /etc/nginx/conf.d/gophish_admin.conf

RUN rm /etc/nginx/conf.d/default.conf

# Expose port 80 for HTTP traffic
EXPOSE 80 443

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]