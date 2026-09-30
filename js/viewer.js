import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { STLLoader } from "three/addons/loaders/STLLoader.js";

export function mountViewer(el) {
  let teardown = () => {};
  let lastStl = undefined;
  let lastReset = undefined;

  function setup(stl) {
    teardown();
    const scene = new THREE.Scene();
    scene.background = new THREE.Color("#e8e9e8");
    const camera = new THREE.PerspectiveCamera(42, 1, 0.1, 2000);
    camera.position.set(72, 62, 85);
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    el.appendChild(renderer.domElement);
    const controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    scene.add(new THREE.HemisphereLight("#ffffff", "#9da5a6", 2.1));
    const light = new THREE.DirectionalLight("#ffffff", 2.6);
    light.position.set(40, 80, 60);
    scene.add(light);
    const grid = new THREE.GridHelper(240, 24, "#c0c5c6", "#d7dada");
    scene.add(grid);
    let mesh;
    if (stl) {
      try {
        const geometry = new STLLoader().parse(stl);
        geometry.computeVertexNormals();
        geometry.computeBoundingBox();
        const bounds = geometry.boundingBox;
        const center = new THREE.Vector3();
        bounds.getCenter(center);
        geometry.translate(-center.x, -center.y, -bounds.min.z);
        geometry.rotateX(-Math.PI / 2);
        mesh = new THREE.Mesh(geometry, new THREE.MeshStandardMaterial({ color: "#d65a34", metalness: 0.08, roughness: 0.72, side: THREE.DoubleSide }));
        scene.add(mesh);
        const size = new THREE.Vector3();
        bounds.getSize(size);
        const span = Math.max(size.x, size.y, size.z, 10);
        camera.position.set(span * 1.7, span * 1.3, span * 1.9);
        camera.near = Math.max(span / 1000, 0.01);
        camera.far = span * 100;
        camera.updateProjectionMatrix();
        controls.target.set(0, size.z * 0.42, 0);
        grid.position.y = -0.1;
        grid.scale.setScalar(Math.max(span / 60, 0.25));
      } catch (error) {
        console.error("STL preview failed", error);
      }
    }
    const resize = () => {
      const w = el.clientWidth, h = el.clientHeight;
      renderer.setSize(w, h);
      camera.aspect = w / Math.max(h, 1);
      camera.updateProjectionMatrix();
    };
    const observer = new ResizeObserver(resize);
    observer.observe(el);
    let frame = 0;
    const animate = () => {
      frame = requestAnimationFrame(animate);
      controls.update();
      renderer.render(scene, camera);
    };
    animate();
    teardown = () => {
      cancelAnimationFrame(frame);
      observer.disconnect();
      controls.dispose();
      mesh?.geometry.dispose();
      mesh?.material?.dispose();
      renderer.dispose();
      if (renderer.domElement.parentNode === el) el.removeChild(renderer.domElement);
    };
  }

  return {
    set(stl, resetKey) {
      if (stl === lastStl && resetKey === lastReset) return;
      lastStl = stl;
      lastReset = resetKey;
      setup(stl);
    },
    dispose() {
      teardown();
    },
  };
}
