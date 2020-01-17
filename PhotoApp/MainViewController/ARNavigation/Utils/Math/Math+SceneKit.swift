//
//  Math+SceneKit.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 1/16/20.
//  Copyright © 2020 Ivan Zhurauski. All rights reserved.
//

import SceneKit
import QuartzCore
#if os(iOS) || os(tvOS)
    typealias SCNFloat = Float
#else
    typealias SCNFloat = CGFloat
#endif

// MARK: SceneKit extensions
public extension SCNVector3 {
    init(_ v: Vector3) {
        self.init(x: SCNFloat(v.x), y: SCNFloat(v.y), z: SCNFloat(v.z))
    }
}

public extension SCNVector4 {
    init(_ v: Vector4) {
        self.init(x: SCNFloat(v.x), y: SCNFloat(v.y), z: SCNFloat(v.z), w: SCNFloat(v.w))
    }
}

#if os(iOS) // SCNWMatrix4 = CATransform3D on Mac
    public extension SCNMatrix4 {
        init(_ m: Matrix4) {
            self.init(
                m11: SCNFloat(m.m11), m12: SCNFloat(m.m12), m13: SCNFloat(m.m13), m14: SCNFloat(m.m14),
                m21: SCNFloat(m.m21), m22: SCNFloat(m.m22), m23: SCNFloat(m.m23), m24: SCNFloat(m.m24),
                m31: SCNFloat(m.m31), m32: SCNFloat(m.m32), m33: SCNFloat(m.m33), m34: SCNFloat(m.m34),
                m41: SCNFloat(m.m41), m42: SCNFloat(m.m42), m43: SCNFloat(m.m43), m44: SCNFloat(m.m44)
            )
        }
    }

#endif

public extension SCNQuaternion {
    init(_ q: Quaternion) {
        self.init(x: SCNFloat(q.x), y: SCNFloat(q.y), z: SCNFloat(q.z), w: SCNFloat(q.w))
    }
}

// MARK: VectorMath extensions
public extension Vector3 {
    init(_ v: SCNVector3) {
        self.init(x: Scalar(v.x), y: Scalar(v.y), z: Scalar(v.z))
    }
}

public extension Vector4 {
    init(_ v: SCNVector4) {
        self.init(x: Scalar(v.x), y: Scalar(v.y), z: Scalar(v.z), w: Scalar(v.w))
    }
}

#if os(iOS) // SCNWMatrix4 = CATransform3D on Mac
    public extension Matrix4 {
        init(_ m: SCNMatrix4) {
            self.init(
                m11: Scalar(m.m11), m12: Scalar(m.m12), m13: Scalar(m.m13), m14: Scalar(m.m14),
                m21: Scalar(m.m21), m22: Scalar(m.m22), m23: Scalar(m.m23), m24: Scalar(m.m24),
                m31: Scalar(m.m31), m32: Scalar(m.m32), m33: Scalar(m.m33), m34: Scalar(m.m34),
                m41: Scalar(m.m41), m42: Scalar(m.m42), m43: Scalar(m.m43), m44: Scalar(m.m44)
            )
        }
    }

#endif

public extension Quaternion {
    init(_ q: SCNQuaternion) {
        self.init(x: Scalar(q.x), y: Scalar(q.y), z: Scalar(q.z), w: Scalar(q.w))
    }
}

// MARK: SceneKit extensions
public extension CGPoint {
    init(_ v: Vector2) {
        self.init(x: CGFloat(v.x), y: CGFloat(v.y))
    }
}

public extension CGSize {
    init(_ v: Vector2) {
        self.init(width: CGFloat(v.x), height: CGFloat(v.y))
    }
}

public extension CGVector {
    init(_ v: Vector2) {
        self.init(dx: CGFloat(v.x), dy: CGFloat(v.y))
    }
}

public extension CGAffineTransform {
    init(_ m: Matrix3) {
        self.init(
            a: CGFloat(m.m11), b: CGFloat(m.m12),
            c: CGFloat(m.m21), d: CGFloat(m.m22),
            tx: CGFloat(m.m31), ty: CGFloat(m.m32)
        )
    }
}

public extension CATransform3D {
    init(_ m: Matrix4) {
        self.init(
            m11: CGFloat(m.m11), m12: CGFloat(m.m12), m13: CGFloat(m.m13), m14: CGFloat(m.m14),
            m21: CGFloat(m.m21), m22: CGFloat(m.m22), m23: CGFloat(m.m23), m24: CGFloat(m.m24),
            m31: CGFloat(m.m31), m32: CGFloat(m.m32), m33: CGFloat(m.m33), m34: CGFloat(m.m34),
            m41: CGFloat(m.m41), m42: CGFloat(m.m42), m43: CGFloat(m.m43), m44: CGFloat(m.m44)
        )
    }
}

// MARK: VectorMath extensions
public extension Vector2 {
    init(_ v: CGPoint) {
        self.init(x: Scalar(v.x), y: Scalar(v.y))
    }

    init(_ v: CGSize) {
        self.init(x: Scalar(v.width), y: Scalar(v.height))
    }

    init(_ v: CGVector) {
        self.init(x: Scalar(v.dx), y: Scalar(v.dy))
    }

    public func toCGPoint() -> CGPoint {
        return CGPoint(self)
    }
}

public extension Matrix3 {
    init(_ m: CGAffineTransform) {
        self.init(
            m11: Scalar(m.a), m12: Scalar(m.b), m13: 0,
            m21: Scalar(m.c), m22: Scalar(m.d), m23: 0,
            m31: Scalar(m.tx), m32: Scalar(m.ty), m33: 1
        )
    }
}

public extension Matrix4 {
    init(_ m: CATransform3D) {
        self.init(
            m11: Scalar(m.m11), m12: Scalar(m.m12), m13: Scalar(m.m13), m14: Scalar(m.m14),
            m21: Scalar(m.m21), m22: Scalar(m.m22), m23: Scalar(m.m23), m24: Scalar(m.m24),
            m31: Scalar(m.m31), m32: Scalar(m.m32), m33: Scalar(m.m33), m34: Scalar(m.m34),
            m41: Scalar(m.m41), m42: Scalar(m.m42), m43: Scalar(m.m43), m44: Scalar(m.m44)
        )
    }
}

public extension LineSegment {
    init(_ p1: CGPoint, _ p2: CGPoint) {
        self.init(Vector2(p1), Vector2(p2))
    }
}
