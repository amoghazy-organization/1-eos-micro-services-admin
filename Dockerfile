FROM openjdk:11
ADD target/ether-0.0.1-RELEASE.jar admin-msvc.jar
CMD ["java","-jar","admin-msvc.jar"]
EXPOSE 8090

