.class public Li0/a;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Li0/a$b;
    }
.end annotation


# instance fields
.field public final a:Lj0/a;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lj0/a<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field

.field public final b:Lio/flutter/embedding/engine/FlutterJNI;

.field private c:Li0/a$b;

.field public final d:Lj0/a$d;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lj0/a$d<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(Lx/a;Lio/flutter/embedding/engine/FlutterJNI;)V
    .locals 4

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Li0/a$a;

    invoke-direct {v0, p0}, Li0/a$a;-><init>(Li0/a;)V

    iput-object v0, p0, Li0/a;->d:Lj0/a$d;

    new-instance v1, Lj0/a;

    sget-object v2, Lj0/q;->a:Lj0/q;

    const-string v3, "flutter/accessibility"

    invoke-direct {v1, p1, v3, v2}, Lj0/a;-><init>(Lj0/c;Ljava/lang/String;Lj0/i;)V

    iput-object v1, p0, Li0/a;->a:Lj0/a;

    invoke-virtual {v1, v0}, Lj0/a;->e(Lj0/a$d;)V

    iput-object p2, p0, Li0/a;->b:Lio/flutter/embedding/engine/FlutterJNI;

    return-void
.end method

.method static synthetic a(Li0/a;)Li0/a$b;
    .locals 0

    iget-object p0, p0, Li0/a;->c:Li0/a$b;

    return-object p0
.end method


# virtual methods
.method public b(ILio/flutter/view/h$g;)V
    .locals 1

    iget-object v0, p0, Li0/a;->b:Lio/flutter/embedding/engine/FlutterJNI;

    invoke-virtual {v0, p1, p2}, Lio/flutter/embedding/engine/FlutterJNI;->dispatchSemanticsAction(ILio/flutter/view/h$g;)V

    return-void
.end method

.method public c(ILio/flutter/view/h$g;Ljava/lang/Object;)V
    .locals 1

    iget-object v0, p0, Li0/a;->b:Lio/flutter/embedding/engine/FlutterJNI;

    invoke-virtual {v0, p1, p2, p3}, Lio/flutter/embedding/engine/FlutterJNI;->dispatchSemanticsAction(ILio/flutter/view/h$g;Ljava/lang/Object;)V

    return-void
.end method

.method public d()V
    .locals 2

    iget-object v0, p0, Li0/a;->b:Lio/flutter/embedding/engine/FlutterJNI;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lio/flutter/embedding/engine/FlutterJNI;->setSemanticsEnabled(Z)V

    return-void
.end method

.method public e()V
    .locals 2

    iget-object v0, p0, Li0/a;->b:Lio/flutter/embedding/engine/FlutterJNI;

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lio/flutter/embedding/engine/FlutterJNI;->setSemanticsEnabled(Z)V

    return-void
.end method

.method public f(I)V
    .locals 1

    iget-object v0, p0, Li0/a;->b:Lio/flutter/embedding/engine/FlutterJNI;

    invoke-virtual {v0, p1}, Lio/flutter/embedding/engine/FlutterJNI;->setAccessibilityFeatures(I)V

    return-void
.end method

.method public g(Li0/a$b;)V
    .locals 1

    iput-object p1, p0, Li0/a;->c:Li0/a$b;

    iget-object v0, p0, Li0/a;->b:Lio/flutter/embedding/engine/FlutterJNI;

    invoke-virtual {v0, p1}, Lio/flutter/embedding/engine/FlutterJNI;->setAccessibilityDelegate(Lio/flutter/embedding/engine/FlutterJNI$a;)V

    return-void
.end method
