# EN ESTO PASOS SI VAMOS A USAR LA IMAGEN DE NODE PARA PODER HACER LAS ISNTALACIONES Y PRUEBAS NECESARIAS PARA PODER MONTAR LO QUE NECESITAMOS PARA LA APLICACION, ESTE PROYECTO SE VA A DESPLEGAR CON SU PROPIO HOSTING USANDO NGINX

# EL PRIMER PASO GENERALMENTE SIEMRPE ES GENERAR LAS DEV-DEPENDENCIES
FROM node:19-alpine3.15 as dev-deps
WORKDIR /app
COPY package.json package.json
RUN yarn install --frozen-lockfile

# EL SIGUIENTE PASO PUEDE SER EL TESTEO Y LA CONSTRUCCION DEL BUILD
FROM node:19-alpine3.15 as builder
WORKDIR /app
COPY --from=dev-deps /app/node_modules ./node_modules
COPY . .
# RUN yarn test
RUN yarn build

# EN ESTA CONSUTRUCCION NO HACE FALTA INSTALAR LAS DEPENDENCIAS DE PRODUCCION, YA QUE COMO SE CONSTRUYO EN EL PASO ANTERIO UN DIST CON EL BUILD ESTA YA VA A TENER EN SUS .JS LO NECESARIO PARA CORRER LA APLICACION

FROM nginx:1.23.3 as prod
EXPOSE 80
# aqui estoy tomando la carpeta del dist que se creo en el stage del builder
#el copy simpre se conforma de 2 rutas el source(el local donde estan mis archivos) y el destination(hacia la imagen) COPY source dest
COPY --from=builder /app/dist /usr/share/nginx/html
#con esto paso las imagenes para que se puedan ver en le servidor
COPY /assets /usr/share/nginx/html/assets
# eliminamos este archivo de configuracion para luego poner el nuestro
RUN rm /etc/nginx/conf.d/default.conf
# aqui colocamos nuestro archivo con la nueva configuracion para que funcione el servidor de nginx con SPA
COPY nginx/nginx.conf /etc/nginx/conf.d/

# con este comando se ejecuta la aplicacion en ngnix
CMD [ "nginx", "-g", "daemon off;" ]
